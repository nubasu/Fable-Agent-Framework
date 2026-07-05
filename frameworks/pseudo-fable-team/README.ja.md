# pseudo-fable-team

[English](README.md) | 日本語

Opus 4.8(PL役)+ Sonnet 5 / Codex(作業者役)の混成チームが、**1枚の AGENTS.md** で Fable 5 級の規律で回るための「チーム憲法」テンプレート。

pseudo-fable ファミリー3部作(blueprint / orchestrate / lift)の蒸留版を、**ロール・ディスパッチ内蔵**の単一ファイルに凝縮したもの。同じ1枚を全員が読み、自分の役割の章だけに従う。

## 使いどころ

1. **ベンダー横断で1枚に統一したい** — AGENTS.md は Codex が読む標準ファイル。Claude 側も CLAUDE.md に `@AGENTS.md` と書けば同じ1枚を読み込む。規律の二重管理(CLAUDE.md と AGENTS.md の内容乖離)を排除できる。
2. **軽量スタート** — フル・ファミリー(常駐コア3種+skills 9種)を導入する前に、まず1枚で始める。
3. **PL/作業者の分業を明示的に振る運用** — Opus=PL、Sonnet/Codex=作業者という本ファイル前提の分業(§1 に標準割当として明記済み)。

## 仕組み — ロール・ディスパッチ(§1)

役割判定は弱いモデルでも迷わないよう機械的:

- プロンプトに `# TASK` ブリーフがある → **Worker**(§4 に従う)
- ユーザーから生の要件を受け、他エージェントに指示できる → **PL**(§3 に従う)
- どちらでもない(単独セッション)→ ユーザーの依頼を Contract とみなし Worker 規律で動く
- 明示の `Role:` 行があれば最優先

さらに「全員 §1–2 → 自分の役割の章 → §5(共有フォーマット)だけ読む」という読み方を先頭で指定し、作業者(Sonnet 級)の注意予算を守る。役割間のインターフェースは §5 のブリーフ9項目/レポート5項目に固定してある(pseudo-fable-orchestrate と同一様式)。

## 各章の要点

- **§2 全役割共通の非交渉ルール5つ** — 未観測の成功報告禁止 / 事実の捏造禁止 / 仮説なきリトライ禁止 / コードが最終審判(矛盾は黙って回避せず停止・報告)/ 既存コードに溶け込む
- **§3 PL** — 要件のテスト可能な契約化と質問1ラウンド束ね(blueprint 蒸留)/ インターフェース凍結→並列化・ルーティング表・ブリーフ必須(orchestrate 蒸留)/ 「報告は主張であって事実ではない」検収 ACCEPT/PATCH/BOUNCE(上限2)/RECLAIM / バウンスのたび「どの一文が欠けていたか」
- **§4 Worker** — Contract 絶対・Non-goals 絶対 / **Stop over improvise**(契約とコードの矛盾・行き詰まりは BLOCKED 即報告、黙った逸脱が唯一の許されない失敗)/ DONE 宣言前の実行証拠と敵対的 diff 再読(lift 蒸留)
- **§5 共有フォーマット** — ブリーフとレポートの様式。ここが役割間の契約なので変更時は全員に効く

## フル・ファミリーとの関係

- 本ファイルは**蒸留版**。深いプロトコル(root-cause-debug の仮説ジャーナル、design-doc の ADR・障害モード分析、トレーサビリティ行列など)は含まない。skills 導入済み環境では **skills が深掘り側、本ファイルは常数側**(ファイル冒頭コメントにも精分け明記)。仕様一式からの本格上流は blueprint 併用を推奨。
- pseudo-fable-orchestrate 同梱の `AGENTS.template.md`(作業者専用・最小版)の**上位互換**。repo root の AGENTS.md は1枚しか置けないため:混成チームを1枚で回す → 本ファイル / リード文脈は CLAUDE.md 側で完結し外部作業者(Codex)への地上ルールだけ欲しい → orchestrate 側の最小版、と使い分ける。
- チームを組まず**単独 Opus** で回すなら、1枚もの同士でも本ファイルではなく `frameworks/pseudo-fable-solo/`(単独フル深度の CLAUDE.md)が適する。本ファイルはロール分業がある前提の蒸留版。

## 導入手順

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks\pseudo-fable-team"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

Copy-Item "$storage\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks/pseudo-fable-team"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

cp "$storage/AGENTS.template.md" "$proj/AGENTS.md"
```

</details>

その後:

1. **Claude Code 側の橋渡し**: プロジェクトの CLAUDE.md 冒頭付近に `@AGENTS.md` の1行を追加(インストール版が AGENTS.md をネイティブに読む場合は不要 — 実挙動を確認)。
2. 末尾 **§6 Project specifics** を埋める(CLAUDE.md 側と重複する場合は同期を保つ)。
3. **Codex**: repo root の AGENTS.md を自動で読む。非対話実行の CLI 形式(`codex exec` 等)はローカルの `codex --help` で確認。

## 正直な限界

- 1枚に収めるための蒸留であり、フル版の網羅性はない(クロスモデル・レビューやプレモーテムは要点のみ)。
- テキスト規律は強制力ではなく強い誘導(ファミリー共通)。作業者の実行環境(特に Codex のサンドボックス)は PL と異なりうるため、検収時の再検証は PL 環境で必ず行う設計にしてある(§3 Economy)。

## 育て方

- ファミリー共通: **再発した失敗から逆算して足す、発火しないルールは削る。**
- 蓄積ポイントは特に2箇所: Worker の BLOCKED 条件(実際に「黙って逸脱された」パターンを条件に昇格)と、PL の Gotchas 定番リスト(プロジェクト固有の罠は §6 に併記してよい)。
