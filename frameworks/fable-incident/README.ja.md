# fable-incident

[English](README.md) | 日本語

障害対応モジュール — 本番影響が出た瞬間の実況プロトコル(**incident-response**)と、解決後の blameless ポストモーテム(**postmortem**)。どのフレームワーク構成にも追加できる。常駐コストは約0.5K トークン。

## 発想 — インシデントは「圧の掛かったデバッグ」ではなく別競技

既存フレームワークはすべて「作る」モードで、目的関数は「正しさ」。インシデントの目的関数は「**影響**」で、優先順位が反転する(原因より止血が先)。下位モデルの典型的失敗は4つ:

1. **出血中に原因究明** — ユーザー影響が続いているのに根本原因を掘り始める。→ 非交渉ルール1「**Mitigate before diagnose**」(ロールバック / フラグ off / フェイルオーバーが先、ナイフ探しは後)
2. **本番での非可逆な実験** — 「直るかもしれない」で再起動・キャッシュクリア・データ変更をして証拠を破壊する。→ 「**本番の状態は証拠**。写真を撮ってから触る」「**可逆か、承認済みか**。同時に変えるのは1つ」
3. **タイムライン不在** — 記録がなく「Xはもう試したっけ?」が答えられない、ポストモーテムが書けない。→ 開始1分目からインシデントファイル(`.claude/state/incident-<date>-<slug>.md`)にタイムスタンプ付きで全行動・全観測を記録
4. **早すぎる全快宣言** — 「良くなった気がする」でクローズ。→ 「**Resolved means observed-healthy**」: 症状の消失を実測+監視ウィンドウ(検知遅延に比例、既定30〜60分)を通過して初めて解決。ポストモーテムが書かれるまでインシデントは閉じない

## 構成

```
fable-incident/
├── INCIDENT.template.md            ← 常駐コア(約0.5K)。プロジェクトの CLAUDE.md 末尾に追記
└── .claude/skills/
    ├── incident-response/          ← TRIAGE → MITIGATE → DIAGNOSE → FIX → VERIFY&MONITOR → CLOSE
    └── postmortem/                 ← タイムライン再構成・3つの所要時間・根本原因と寄与要因・3レンズの改善項目
```

## incident-response の要点

- **入口チェック** — いま本番影響があるか?なければ通常ループ(root-cause-debug)へ。「非インシデントにインシデントを走らせない」も規律のうち。
- **TRIAGE は5分まで** — 影響範囲(拡大中か?)と「**何が変わったか**」(デプロイ・設定・依存・トラフィック・データ・外部サービス)。インシデントの大半は直近の変更に相関する。
- **MITIGATE** — 最速の可逆レバー優先順: ロールバック > フラグ off > フェイルオーバー(状態保全してから)> スケール。数値で効果確認。「緩和≠解決」。
- **DIAGNOSE** — lift の root-cause-debug に本番制約(読み取り優先・実験は可逆か承認済み)を被せて実行。
- **FIX** — 緊急でも finish-gate は免除されない(未検証ホットフィックスは今夜2件目のインシデントの作り方)。同種バグの grep も忘れない。
- **権限がない場合** — エージェントが本番操作権を持たないときは「実行」ではなく「指揮」に切り替わる: 正確なコマンド+可逆性を提示し、ユーザーが実行・承認する。プロトコル自体は不変。

## postmortem の要点

- **Blameless** — 落ちるのはシステムとプロセスであって人(やモデル)ではない。「誰がやったか」ではなく「なぜシステムはそれを許したか」。エージェントのミス=欠けていたチェック。
- **3つの所要時間**(検知まで・止血まで・解決まで)をそれぞれ別の改善対象として計測。
- **幸運は今回発火しなかったリスク** — 「たまたま助かった」も所見として値付けする。
- **3レンズの改善項目** — 早く気づく(監視)/ 類を殺す(インスタンスでなくクラスの再発防止)/ 早く止める(ロールバック手段・runbook)。改善項目はチケットなので数の上限なし。**文脈ルール**にするものだけ retro の配置表と「≤2ルール」制約を通す。
- 置き場は `docs/postmortems/`(人間可視の恒久文書)。1ページ以内 — 読まれないポストモーテムは何も防がない。

## 他フレームワークとの接続

| 接続先 | 関係 |
|---|---|
| lift `root-cause-debug` | DIAGNOSE フェーズの中身(仮説ジャーナル)。incident 側は本番制約を上掛けする |
| lift `finish-gate` | FIX フェーズでも免除されない |
| retro | ポストモーテムの教訓の配置先(未導入なら CLAUDE.md へ直接) |
| session-bootstrap | インシデントファイルも state の一部として OPEN/CLOSE で拾われる |

未導入でも単体で動く(診断は skill 内の要点で代替)。

## 導入手順

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks\fable-incident"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. 常駐コアを CLAUDE.md 末尾に追記
Get-Content "$storage\INCIDENT.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. skills をコピー(.claude/skills/ に追加される)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Fable-Agent-Framework/frameworks/fable-incident"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

cat "$storage/INCIDENT.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

他フレームワークとの組み合わせ導入は、ストア直下の README.ja.md を参照。

## 正直な限界

- 監視基盤(メトリクス・アラート)がないプロジェクトでは検知と効果測定が弱くなる。プロトコルはそれ自体を「可観測性の欠如=最優先アクションアイテム」として扱う設計。
- 監視ウィンドウの長さは目安運用(検知遅延に比例させる)。
- テキスト規律は強制力ではなく強い誘導(ファミリー共通)。特に「止血が先」は時間圧下で破られやすいため、非交渉ルールの筆頭に置いてある。
