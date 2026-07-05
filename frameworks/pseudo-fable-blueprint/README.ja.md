# pseudo-fable-blueprint

[English](README.md) | 日本語

与えられた仕様に対して、Opus 4.8 が Fable 5 級に設計・planning・ticket 化・その他必要な上流作業をこなすためのコンテキストフレームワーク。

pseudo-fable ファミリーの3作目で、パイプラインの最上流を担う:

```
仕様 ──▶ pseudo-fable-blueprint ──▶ pseudo-fable-orchestrate ──▶ pseudo-fable-lift
        (設計・計画・チケット)   (委任・検収)          (実行規律)
```

- **pseudo-fable-blueprint** — 仕様をチケットに変える(頭の中を文書に変える)
- **pseudo-fable-orchestrate** — チケットをブリーフに変えて委任・検収する
- **pseudo-fable-lift** — 手を動かす側の規律

チケット様式はそのまま orchestrate のブリーフ9項目に 1:1 でマップされる(ticketize §6)ため、仕様から検証済みコードまで全ホップに規律が通る。

## 発想 — 下位モデルの上流工程の失敗は5点に集約される

1. **仕様の鵜呑み** — 曖昧さ・矛盾・欠落・暗黙の非機能要件を見ずに設計に入る。**仕様は主張であって真実ではない**。
2. **最初の思いつきに錨を下ろす** — 代替案の比較なしに最初のアーキテクチャで走る。
3. **グリーンフィールド妄想** — 既存コードベースの現実(慣習・インフラ・データ)を無視した設計。**recon してから設計**。
4. **ハッピーパス設計** — 障害モード・エッジケース・移行・ロールバックが実装中に初めて発覚する。
5. **黙って落とす** — 要件がチケットに落ちず消える。テスト戦略・移行・可観測性・docs など「その他必要な作業」が漏れる。→ **トレーサビリティ行列と忘れ物チェックリストの強制**。

### 正直な効能書き

- **上がるもの**: 要件の取りこぼし率、設計判断の記録性(下流での蒸し返し防止)、リスクの発見時期(統合時→計画時)、チケットの実行可能性。
- **上がらないもの**: 個々の設計判断の深さそのもの(探索の幅はプロトコルで強制できるが、判断の質はモデル依存)。最重要の ADR は上位モデル(Fable)のセッションで下すハイブリッド運用を推奨。
- pseudo-fable-lift の `deep-plan` との棲み分け: deep-plan は単一タスク着手前の軽量版。仕様一式から起こす場合は本フレームワークを使う。

## 構成

```
pseudo-fable-blueprint/
├── BLUEPRINT.template.md           ← 常駐コア(約1.0Kトークン)。プロジェクトの CLAUDE.md 末尾に追記
└── .claude/skills/                 ← フェーズごとのプロトコル(発火時のみ読込)
    ├── spec-interrogate/           ← INTAKE:仕様の尋問 → テスト可能な要件台帳・質問/仮定の triage
    ├── design-doc/                 ← DESIGN:recon → 複数案比較 → 障害モード分析 → ADR → プレモーテム
    └── ticketize/                  ← PLAN:walking skeleton・リスク先行・依存グラフ・チケット・行列
```

設計上の要点:

- **フェーズゲート制** — INTAKE → DESIGN → PLAN & TICKETS。ゲートが開いたまま次フェーズに入らない(「要件が固まってないのに設計」「設計判断が未記録なのにチケット化」を遮断)。
- **質問は1ラウンドに束ねる** — 尋ねるのは「重大かつ後から変えにくい」点だけ(目安≤5問、各問に推奨デフォルト付き)。残りは影響評価付きの仮定台帳へ。質問攻めと黙った思い込みの両方を防ぐ。
- **成果物はチャットでなくファイル** — `docs/plan/<slug>/01-requirements.md / 02-design.md / 03-tickets.md`。チャットは蒸発するが、ファイルは下流エージェントが食える。
- **仕様変更はデルタ再尋問** — 変更が来たらチケットを直接いじらず、spec-interrogate を差分に再適用してトレーサビリティ行列経由で伝播させる。

## 導入手順

他フレームワークとの組み合わせ導入(推奨フルスタック等)は、ストア直下の README.ja.md を参照。

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-blueprint"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. skills をコピー(.claude/skills/ に追加される)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 2. 常駐コアを CLAUDE.md 末尾に追記
Get-Content "$storage\BLUEPRINT.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-blueprint"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
cat "$storage/BLUEPRINT.template.md" >> "$proj/CLAUDE.md"
```

</details>

GitHub Issues 等の外部トラッカーへの起票は任意(外部可視のためユーザー確認必須、ファイルが正)。

## 運用ルール(育て方)

- ファミリー共通:**ルールは再発した失敗から逆算して足し、発火しないルールは削る。**
- 特に蓄積価値が高いのは spec-interrogate の「hunt レンズ」(実際に見逃した穴のパターンを足す)と、design-doc §5 の cross-cutting リスト(そのドメインで毎回必要になる観点を足す)。

## 既知の限界

- テキストによる規律は強制力ではなく強い誘導(ファミリー共通)。
- 見積り(size/uncertainty)は実装者がエージェントの場合、実時間より「コンテキスト消費量・往復回数」の代理指標として読むこと。点見積りを信じない運用はプロトコル側に組み込み済み(レンジ+確信度)。
