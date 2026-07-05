# pseudo-fable-orchestrate

[English](README.md) | 日本語

Opus 4.8 をリード役として、サブエージェント(Sonnet 5 / Codex 等)への指示出し・検収を Fable 5 級に引き上げるコンテキストフレームワーク。

`pseudo-fable-lift` の姉妹フレームワーク。役割分担:

- **pseudo-fable-blueprint** — 仕様から設計・計画・チケットを起こす規律(上流。チケットが本フレームワークのブリーフに 1:1 マップされる)
- **pseudo-fable-lift** — 自分の手を動かす規律(検証・デバッグ・報告)
- **pseudo-fable-orchestrate** — 人に(エージェントに)やらせる規律(委任・検収・統合)

リード役セッションには両方の導入を推奨。pseudo-fable-lift なしでも動作するが、`deep-plan` と `long-task-state` への参照が最大限に活きるのは併用時。

なお、ファミリー全体をロール・ディスパッチ内蔵の1枚に蒸留した `frameworks/pseudo-fable-team/`(AGENTS.md 版チーム憲法)もある。repo root の AGENTS.md は1枚しか置けないため:混成チーム(PL+作業者)を1枚で回すなら pseudo-fable-team 版、リード文脈は CLAUDE.md で完結し外部作業者向け地上ルールだけ必要なら本フレームワーク同梱の最小版 `AGENTS.template.md`、と使い分ける(pseudo-fable-team 版は最小版の上位互換)。

## 発想 — 下位モデルのオーケストレーション失敗は3点に集約される

1. **曖昧なブリーフ** — 「認証機能を実装して」だけ投げて、サブエージェントの推測とドリフトを招く。**ブリーフの質が出力の上限**であり、失敗の第一容疑者は常にブリーフ。
2. **報告の鵜呑み** — サブエージェント(特に下位モデル)は成功を過大報告する。**報告は証言であって証拠ではない**。独立検証なしの統合は事故のもと。
3. **無計画な並列化** — インターフェースを凍結せずにファン・アウトし、マージ時に意味的衝突。**凍結してから並列化、統合は自分の仕事**。

上位モデルはこの3点を暗黙に回避する。本フレームワークはそれを明文化し、発火条件付きプロトコルとして課す。

### 正直な効能書き

- **上がるもの**: 委任タスクの成功率、手戻り回数、統合事故率、リード役自身のコンテキスト効率。
- **上がらないもの**: サブエージェント自体の能力(それは各エージェント側の pseudo-fable-lift / AGENTS.md の仕事)。また、そもそも委任に向かない仕事(曖昧な要件、横断的設計)を委任可能にはしない — ルーティング表はむしろ「委任するな」を明示する。

## 構成

```
pseudo-fable-orchestrate/
├── ORCHESTRATE.template.md         ← リード役の常駐コア(約0.9Kトークン)。プロジェクトの CLAUDE.md 末尾に追記
├── AGENTS.template.md              ← Codex 等の外部エージェント向け地上ルール。リポジトリ直下に AGENTS.md として配置
└── .claude/skills/                 ← オンデマンド・プロトコル(発火時のみ読込)
    ├── delegate/                   ← 分解・ルーティング・9項目ブリーフ・並列化ルール
    └── accept-work/                ← 検収:独立検証 → ACCEPT/PATCH/BOUNCE/RECLAIM
```

設計上の要点:

- **ブリーフは executor 非依存** — 同じ9項目フォーマットが Claude サブエージェント(Agent ツール)にも Codex(`codex exec`)にも通る。リトマス試験は「セッション文脈ゼロの有能な他人が実行できるか」(Codex は文字通りそれ)。
- **検収は4値分類** — ACCEPT / PATCH(些事は往復させず自分で直す)/ BOUNCE(証拠付き・具体的な差し戻し、上限2回)/ RECLAIM(3回目のバウンスは禁止、ブリーフを書き直して再委任か引き取り)。
- **バウンスごとにブリーフの事後検証** — 「どの一文が欠けていたか」を特定して足す。これが委任品質を上げるフライホイール。
- **異種モデル相互レビュー** — リスクの高い diff は別系統モデル(Codex ↔ Claude)に敵対的レビューさせる。モデル間の不一致は「自分で見ろ」のシグナル。
- **Sonnet 級向けブリーフ・チューニング(v1.1、delegate §3b)** — 受け手が Sonnet のとき、完全性に加えて「機械的に読めること」を要求: 簡潔第一(同じ決定なら300行より60行が勝つ)/ 決められることは全部先に決める(開いた点は質問ではなく黙った推測で埋まる)/ 契約は散文でなくテストで(入出力例1つが説明1段落に勝る)/ ファイル許可リストで柵を作る / エスカレーション条件は機械的に(「契約が変だと思ったら」ではなく「許可リスト外のファイルが要る」等)。
- **Pre-send check(v1.1、delegate §3c)** — 送信前に PL 自身のブリーフを検査: Pointers のパスが実在するか、Done means のコマンドが実際に動くか、「適宜」「など」が残っていないか。幻覚パス入りブリーフは全額払いで失敗する。

## 導入手順

他フレームワークとの組み合わせ導入(推奨フルスタック等)は、ストア直下の README.ja.md を参照。

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-orchestrate"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. skills をコピー(.claude/skills/ に追加される)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 2. リード役コアを CLAUDE.md 末尾に追記
Get-Content "$storage\ORCHESTRATE.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 3. Codex を使う場合のみ:外部エージェント向けルールを配置
Copy-Item "$storage\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-orchestrate"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
cat "$storage/ORCHESTRATE.template.md" >> "$proj/CLAUDE.md"
cp "$storage/AGENTS.template.md" "$proj/AGENTS.md"   # Codex を使う場合のみ
```

</details>

その後、AGENTS.md 末尾の Project specifics を CLAUDE.md 側と同期させる(ビルド・テストコマンドは外部エージェントにも必要)。

## Codex 連携の注意

- Codex は CLAUDE.md を読まない。共有されるのは **ブリーフ + AGENTS.md だけ**という前提で delegate skill は書かれている。
- 非対話実行の CLI 形式(`codex exec` 等)はバージョンで変わりうるため、導入先でローカルの `codex --help` を確認すること(delegate skill 内にも同旨の注記あり)。
- 実行環境がリード役と異なる(サンドボックス等)可能性があるため、検収時の再検証はリード役の環境で必ず行う。

## Delegation-first(v1.2)— 実装は既定でワーカーへ。ただし禁止ではなく判断

「Opus は一切実装しない」という硬い禁止ではなく、Fable 級のリードが実際に使う判断基準を明文化したもの(v1.1 の hands-on / hands-off モード切替は本原則に置き換えて廃止)。**実装は既定で委任**し、自分で手を動かすのは次の4条件が**すべて**成り立つときだけ:

1. 仕様化のほうが実行より高くつく(目安 15 分未満の機械的作業で、中に設計判断がない)
2. 実装文脈に深入りしない(頭に入れるファイルが2〜3を超えるなら委任)
3. いま自分を待っているワーカー・並列ストリームがない
4. 低リスクで可逆(凍結インターフェース上でも、クリティカルパス上でもない)

**迷ったら委任**(PL のコンテキストはシステム内で最も希少な資源)。溜まったマイクロタスクは1ブリーフに束ね、都度のコンテキストスイッチを避ける。検証・統合は常に PL の仕事(検証は実装ではない — accept-work はむしろ必須としている)。

検収側も同じ判断: PATCH は原則インライン修正(些事を往復させるほうが無駄)だが、複数ファイルや設計判断を伴い実装に深入りするならパッチブリーフで実装者に返す。厳格に「一切実装しない」で回したいセッションはユーザー指示での上書きで対応(ユーザー指示が常に優先)。

狙いはレバレッジ: 実装に使わなかったトークンを仕様化と検証に再投資する(Gotchas を厚く、契約をテストで固く、検収を深く、並列本数を多く)。実装側の底上げには、ワーカーが継承する CLAUDE.md に pseudo-fable-lift を入れておくことを強く推奨(Claude サブエージェントはプロジェクトの CLAUDE.md を読む)。

## 運用ルール(育て方)

- pseudo-fable-lift と同じ:**ルールは再発した失敗から逆算して足し、発火しないルールは削る。**
- 特に蓄積価値が高いのは delegate skill の Gotchas 欄の「定番の罠リスト」と、accept-work の事後検証で見つかった「欠けていた一文」。プロジェクト固有の頻出項目は Project specifics ではなく標準ブリーフの雛形側に昇格させる。

## 既知の限界

- テキストによる規律は強制力ではなく強い誘導(pseudo-fable-lift と同じ)。検収の機械的な後押し(サブエージェントが戻るたびの PostToolUse ナッジ)はオプションの `frameworks/pseudo-fable-harness/` に実装済み。
- 並列ファン・アウトのコストは実費。ルーティング表の「~15分未満は自分でやる」を守るだけで大半の無駄は消える。
