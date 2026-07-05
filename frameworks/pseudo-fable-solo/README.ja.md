# pseudo-fable-solo

[English](README.md) | 日本語

**単独の Opus 4.8 セッション**を Fable 5 級の仕事ぶりに引き上げる、**1ファイル完結**のコンテキストフレームワーク。チームなし・skills ディレクトリ不要。`CLAUDE.template.md` をプロジェクト直下に `CLAUDE.md` として置くだけで動く。

## pseudo-fable-lift との違い(どちらも「単体の底上げ」だが)

| | pseudo-fable-lift | pseudo-fable-solo |
|---|---|---|
| 構成 | 2層(常駐コア 約1.2K + skills 5種を都度読込) | 1枚(約3K 常駐、プロトコル §P1–P5 をインライン化) |
| 対象 | Opus / Sonnet 汎用 | **Opus 専用**チューニング |
| skills 発火リスク | あり(呼ばれなければプロトコルは働かない) | **ゼロ**(常に文脈内にある) |
| 導入 | CLAUDE.md + .claude/skills/ のコピー | ファイル1つのコピー |
| 向く場面 | Sonnet も走る環境、常駐を最小にしたい | Opus 単独運用、確実性優先、手軽さ優先 |

判断基準: Sonnet にも同じ規律を課すなら lift(Sonnet の注意予算に 3K 常駐は重い)。**Opus 単独なら solo** — Opus は 3K 常駐を消化でき、skills 発火失敗というプロトコルの穴が消える方が利得が大きい。

## 発想 — Opus→Fable の「残差ギャップ」を直接狙う

Sonnet→Fable のギャップ(基本規律の欠落)とは異なり、Opus 4.8 の残差は挙動の質に現れる。本ファイルは5つを名指しで潰す:

1. **早すぎる収束** — 最初の筋の良い仮説・設計に錨を下ろす。→「まず評価せずに本質的に異なる候補を2〜3出す」を意思決定の既定動作に(§How to spend intelligence #1)。
2. **雄弁バイアス** — 精巧な推論を精巧さゆえに信じる。→「**Evidence outranks eloquence**」: 前提はリポジトリで検証、結論は実行で検証。両端が繋がるまで推論は仮説(同 #2)。
3. **検証の深度不足** — 目先のチェックは回すが二次影響(呼び出し元・状態・並行性)を見ない。→ blast radius と敵対的再読を finish-gate に固定(§P3 C/D)。
4. **長期ドリフト** — 3時間目の品質低下、終盤の「たぶん大丈夫」。→「**Finish at full strength**」+ §P4 の外部ステート(同 #5)。
5. **taste(過剰設計)** — 抽象の先回り、防御的な複雑さ。→ §Taste: 「新しい抽象は今日2つの呼び出し元がなければ欠陥」「賢い解はコードベースの高度に合わなければ誤答」。

もう一つの solo 固有の工夫: 単独ではレビュアーの新鮮な目がないため、**finish-gate の Gate B(ビルド・テスト実行)を先に回してから diff を再読**する順序を固定し、「書いた直後の自分」と「読み直す自分」の間に時間差を作る(§P3 C — フレッシュアイズの自前調達)。

## 構成

```
pseudo-fable-solo/
├── CLAUDE.template.md   ← これ1枚(約3Kトークン常駐)。コピー先で CLAUDE.md に改名
└── README.md            ← 人間向け README(英語版。日本語版は本ファイル README.ja.md)
```

中身の骨格: 非交渉ルール5(ファミリー共通の常数)→ How to spend intelligence(Opus 固有)→ 作業ループ → §P1 deep plan / §P2 root-cause debug / §P3 finish gate / §P4 long-task state / §P5 test protocol(lift の skills 5種の凝縮インライン版)→ Taste → トリガー表。

## 導入手順

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-solo"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

Copy-Item "$storage\CLAUDE.template.md" "$proj\CLAUDE.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-solo"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

cp "$storage/CLAUDE.template.md" "$proj/CLAUDE.md"
```

</details>

その後、新プロジェクトで `/init` を実行し、生成物を末尾 **Project specifics** にマージ(フレームワーク部分は残す)。

## ファミリー内の位置づけ

- **pseudo-fable-solo** — 単独セッション・1枚・フル深度(本フレームワーク)
- **pseudo-fable-lift** — 単体底上げの2層版(Opus/Sonnet 汎用)
- **pseudo-fable-team** — 混成チーム(PL+作業者)の蒸留1枚版(AGENTS.md)
- **pseudo-fable-blueprint / pseudo-fable-orchestrate** — 上流工程/委任・検収(チーム運用時に solo・lift と併用)

solo で始めて、作業者(Sonnet/Codex)を足す段になったら team か orchestrate に移行するのが自然な成長パス。

## 正直な限界

- 常駐 約3K トークンは毎セッションのコスト。小タスク中心の運用なら lift の2層が軽い。
- 素の推論力・知識は変わらない(ファミリー共通)。本ファイルが変えるのは「ステップの間で何をするか」。
- テキスト規律は強制力ではなく強い誘導(ファミリー共通)。

## 育て方

- ファミリー共通: **再発した失敗から逆算して足す、発火しないルールは削る。**
- solo 固有の蓄積ポイント: §Taste(そのコードベースで実際に出た過剰設計パターン)と §P3 C の hunt リスト(実際に見逃したバグ類型)。
