# pseudo-fable-retro

[English](README.md) | 日本語

継続運用モジュール — **学習のリズム(retro)** と **セッションのリズム(session-bootstrap)** の skills 2種で、長期運用の2大漏れを塞ぐ。どのフレームワーク構成にも追加でき、単体でも動く。常駐コストは約0.3K トークン。

1. **教訓の蒸発** — 各フレームワークの README に「再発した失敗から逆算して足す・発火しないルールは削る」と書いてあるが、それを実行するプロトコルとトリガーが存在しなかった。助言は仕組みではない。retro はこの育成ルールをプロトコル化したもの。
2. **文脈の蒸発** — セッションを跨ぐたびに「どこまでやったっけ」へ最初の30分を浪費するか、記憶で再開してドリフト事故を起こす。session-bootstrap は起動と終了の儀式を固定する。

## 構成

```
pseudo-fable-retro/
├── RETRO.template.md            ← 常駐トリガー(約0.3K)。プロジェクトの CLAUDE.md 末尾に追記
└── .claude/skills/
    ├── retro/                   ← 収穫 → 「どの一文があれば防げたか」→ 配置表 → 棚卸し
    └── session-bootstrap/       ← OPEN(ファイルから復元・ドリフト検証)/ CLOSE(チェックポイント)
```

## retro — ルールは失敗から育てる(仕組み版)

発火: マイルストーン完了時 / バウンス・リクレーム・修正スパイラル発生時 / 週次(または10タスクごと)の棚卸し。

1. **収穫** — 失敗(バウンス、差し戻し、長生きした誤仮定)、抵抗(2回以上かかったもの、既知の罠の再発見)、驚き(=値付けされていなかったリスク)を1行ずつ。
2. **欠けていた一文** — 「どの文書のどの一文があれば防げたか」。文にできないなら失敗をまだ理解していない。
3. **配置表** — 教訓のスコープに応じて**最も狭い置き場**へ: リポジトリの罠 → Gotchas / ワーカーが繰り返し踏む罠 → PL の標準ブリーフ Gotchas / プロジェクト固有のプロセス失敗 → プロジェクト CLAUDE.md / どのプロジェクトでも再発する汎用 → **ストアのテンプレ(編集はユーザーに提案** — 全プロジェクト共有物のため**)** / ユーザーの特性 → エージェントの memory / 一回きり → **どこにも書かない**。
4. **棚卸し** — 発火していないルールは削除か格下げ、誤発火は書き直し。「削るのは足すのと同じ価値。足すだけの retro は壊れている」。
5. **抑制** — 1回の retro で足すのは**最大2ルール**。ルール・インフレは retro 自身の失敗モード。

## session-bootstrap — セッションはファイルから起動する

**OPEN**(過去の作業を継続するセッションの開始時): state → delegations ledger → tickets → `git log`/`git status` の順に読む → 重要事実の上位3つをコードで再検証(ドリフト検出)→ 「現在地 X/Y・次の一手・ドリフト有無」を1メッセージで宣言してから再開。**計画済みの再計画はしない**(セッションが最初の1時間を失う典型)。

**CLOSE**(終了時・コンテキスト満杯間際): state 更新(**Next action を必ず具体的な1手**で残す)→ tickets/ledger 更新 → 作業ツリーを意図的に駐機(コミット権限がなければ未コミット内容を正確に報告)→ 何か転んだ回なら micro-retro → 3行ハンドオフ(今日やった / 次の一手 / 開いているリスク)。

コンパクション後の再開も「変装した新セッション」として OPEN を回す(anti-patterns に明記)。

## 他フレームワークとの棲み分け

| | 定めるもの |
|---|---|
| lift の `long-task-state` | 状態ファイルの**形式**(何を書くか) |
| `session-bootstrap` | それを読み書きする**儀式**(セッションの開始・終了に何をするか) |
| orchestrate の `accept-work` §3 | バウンス単位のブリーフ事後検証(個別) |
| `retro` | 全教訓の**配置と棚卸し**(どこに書き、いつ削るか) |

state ファイルや ledger がない構成でも動く(git log と docs から復元し、教訓はプロジェクト CLAUDE.md へ)。

## 導入手順

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-retro"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. 常駐トリガーを CLAUDE.md 末尾に追記
Get-Content "$storage\RETRO.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. skills をコピー(.claude/skills/ に追加される)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-retro"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

cat "$storage/RETRO.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

他フレームワークとの組み合わせ導入は、ストア直下の README.ja.md を参照。

## 正直な限界

- retro の質は自己認識に依存する(自分の失敗と認識できなかったものは収穫できない)。バウンス・差し戻し・テスト失敗など**観測可能なイベント**を主トリガーにしているのはこの弱点を減らすため。
- 棚卸しの「発火記録」は厳密には取れない(目安運用)。「最近このルールが行動を変えたか」でざっくり判断する。
- ストアのテンプレへの還元はユーザー承認制のため、汎用教訓の反映は人間がボトルネックになる(意図的な設計 — 共有物の無断改変より安全)。
