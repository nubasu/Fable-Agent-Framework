# Fable-Agent-Framework — fable フレームワーク導入ガイド

[English](README.md) | 日本語

新規プロジェクトに fable ファミリー(エージェント規律のコンテキストフレームワーク群)を投入するための手順集。各フレームワークの設計思想・詳細は各ディレクトリの README.ja.md を参照。

## 収録フレームワーク

| フレームワーク | 役割 | 形態 |
|---|---|---|
| `fable-solo` | 単独 Opus の実行規律(プロトコルをインライン化した完全版) | CLAUDE.md 1枚 |
| `fable-lift` | 実行規律の2層版。Opus/Sonnet 汎用、**ワーカーの底上げにも使う** | CLAUDE.md コア + skills 5種 |
| `fable-orchestrate` | PL(Opus)の委任・検収規律(Delegation-first) | CLAUDE.md 追記 + skills 2種 + Codex 用最小 AGENTS.md |
| `fable-blueprint` | 仕様 → 設計 → 計画 → チケットの上流規律 | CLAUDE.md 追記 + skills 3種 |
| `fable-team` | PL+ワーカー混成チームの蒸留1枚版(ロール・ディスパッチ内蔵) | AGENTS.md 1枚 |
| `fable-retro` | 継続運用: セッション跨ぎの復元(session-bootstrap)+ルール育成(retro) | CLAUDE.md 追記 + skills 2種 |
| `fable-incident` | 障害対応: 止血優先の実況プロトコル(incident-response)+ blameless ポストモーテム(postmortem) | CLAUDE.md 追記 + skills 2種 |

## まず構成を選ぶ

| 運用 | 入れるもの | 常駐トークン目安 |
|---|---|---|
| Opus 単独で全部やる | fable-solo | 約3K |
| 単独・軽量2層で(Sonnet も走らせる) | fable-lift | 約1.2K+skills都度 |
| **Opus=PL、Sonnet=実装(推奨フルスタック)** | fable-lift + fable-orchestrate | 約2.1K |
| ↑に仕様起点の上流も | + fable-blueprint | 約3.1K |
| ↑に Codex ワーカーも | + AGENTS.md(orchestrate 同梱の最小版) | 同上 |
| まず1枚だけで試す(混成チーム) | fable-team | 約1.5K |
| + 継続運用(セッション復元・ルール育成。全構成に追加可) | + fable-retro | +約0.3K |
| + 障害対応(本番を運用するなら。全構成に追加可) | + fable-incident | +約0.5K |

**排他ルール(重複導入しない):**

- CLAUDE.md のベースは **solo か lift のどちらか一方**。solo は skills 不要(インライン済み)なので skills とも併用しない。
- repo root の AGENTS.md は1枚だけ: **team 版か orchestrate 最小版のどちらか一方**(team 版は最小版の上位互換)。

**成長パス:** solo(または team)で開始 → ワーカーを組む段階で lift+orchestrate へ移行 → 大きめの機能開発が始まったら blueprint を追加。fable-retro は小さく全構成互換なので、マルチセッション運用なら最初から入れてよい。本番運用が始まったら fable-incident を足す。

## 導入手順

この repo を任意の場所に clone(または ZIP 展開)し、共通変数を自分の環境に合わせて設定する(以降のスニペットで使用)。各シナリオは Windows PowerShell → macOS / Linux(bash)の順でコマンドを併記する。

Windows(PowerShell):

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks"   # ← この repo を置いた場所
$proj    = "C:\path\to\new-project"                        # ← 導入先プロジェクト
```

macOS / Linux(bash):

```bash
storage="/path/to/Fable-Agent-Framework/frameworks"   # ← この repo を置いた場所
proj="/path/to/new-project"                           # ← 導入先プロジェクト
```

### A. Opus 単独(最短)

```powershell
Copy-Item "$storage\fable-solo\CLAUDE.template.md" "$proj\CLAUDE.md"
```

```bash
# macOS / Linux
cp "$storage/fable-solo/CLAUDE.template.md" "$proj/CLAUDE.md"
```

### B. 推奨フルスタック(Opus=PL、Sonnet=実装)

```powershell
# 1) CLAUDE.md を組み立てる(ベース = lift、orchestrate を追記)
Copy-Item "$storage\fable-lift\CLAUDE.template.md" "$proj\CLAUDE.md"
Get-Content "$storage\fable-orchestrate\ORCHESTRATE.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2) skills を集約コピー(計7種)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-lift\.claude\skills\*"        "$proj\.claude\skills\"
Copy-Item -Recurse -Force "$storage\fable-orchestrate\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cp "$storage/fable-lift/CLAUDE.template.md" "$proj/CLAUDE.md"
cat "$storage/fable-orchestrate/ORCHESTRATE.template.md" >> "$proj/CLAUDE.md"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-lift/.claude/skills/"*        "$proj/.claude/skills/"
cp -R "$storage/fable-orchestrate/.claude/skills/"* "$proj/.claude/skills/"
```

Sonnet ワーカー(Claude サブエージェント)はプロジェクトの CLAUDE.md を継承するため、lift 部分がそのままワーカーの実行規律になる(PL のブリーフ品質 × ワーカーの実行規律の掛け算)。

### C. 仕様起点の上流を足す(B に追加)

```powershell
Get-Content "$storage\fable-blueprint\BLUEPRINT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
Copy-Item -Recurse -Force "$storage\fable-blueprint\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-blueprint/BLUEPRINT.template.md" >> "$proj/CLAUDE.md"
cp -R "$storage/fable-blueprint/.claude/skills/"* "$proj/.claude/skills/"
```

### D. Codex ワーカーを足す(B/C に追加)

```powershell
Copy-Item "$storage\fable-orchestrate\AGENTS.template.md" "$proj\AGENTS.md"
```

```bash
# macOS / Linux
cp "$storage/fable-orchestrate/AGENTS.template.md" "$proj/AGENTS.md"
```

- 非対話実行の CLI 形式(`codex exec` 等)をローカルの `codex --help` で確認する。
- AGENTS.md 末尾の Project specifics を CLAUDE.md 側と同期する(Codex にもビルド・テストコマンドが要る)。

### E. 1枚だけで軽量スタート(混成チーム)

```powershell
Copy-Item "$storage\fable-team\AGENTS.template.md" "$proj\AGENTS.md"
```

```bash
# macOS / Linux
cp "$storage/fable-team/AGENTS.template.md" "$proj/AGENTS.md"
```

- Claude 側の橋渡し: プロジェクトの CLAUDE.md 冒頭付近に `@AGENTS.md` の1行を追加する(お使いの Claude Code が AGENTS.md をネイティブに読む場合は不要 — 実挙動を確認)。

### F. 継続運用モジュールを足す(全シナリオに追加可)

```powershell
Get-Content "$storage\fable-retro\RETRO.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-retro\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-retro/RETRO.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-retro/.claude/skills/"* "$proj/.claude/skills/"
```

- セッション跨ぎの復元(session-bootstrap)とルール育成(retro)。マルチセッションの実務では最初から入れておくことを推奨。
- E(fable-team 1枚)構成でも、`@AGENTS.md` の橋渡し行を書いた CLAUDE.md に追記すれば併用できる。

### G. 障害対応モジュールを足す(本番を運用するプロジェクト向け、全シナリオに追加可)

```powershell
Get-Content "$storage\fable-incident\INCIDENT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-incident\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-incident/INCIDENT.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-incident/.claude/skills/"* "$proj/.claude/skills/"
```

- 本番影響が出た瞬間の実況プロトコル(止血→診断の順序厳守・証拠保全・タイムライン)と、解決後の blameless ポストモーテム。診断は lift の root-cause-debug、教訓の配置は retro に接続する(未導入でも単体で動く)。

## 共通仕上げ(全シナリオ)

1. **Project specifics を埋める** — 新プロジェクトで Claude Code を開き `/init` を実行。生成されたビルド・テスト・アーキテクチャ情報を CLAUDE.md の「Project specifics」節にマージする(フレームワーク節は削らない)。AGENTS.md がある場合は同名節も同期する。追記順の都合で Project specifics 節がファイル中間に来ることがあるが、動作に影響はない。
2. **.gitignore に追記** — `.claude/state/`(long-task-state のステートファイルと delegations ledger の置き場)。
3. **動作確認** — 新セッションを開き、(a) skills 構成なら「利用可能な skills を列挙して」で fable 系(deep-plan / finish-gate / delegate 等)が見えるか、(b) 小さいタスクを1つ流し、完了報告の前に finish-gate(solo なら §P3)が発火するかを確認する。
4. **効きの調整** — 数タスク回して、発火しないルールは削り、再発した失敗はルール化する(各 README の「育て方」参照)。テンプレ側に還元する価値のある改善は本ストアのファイルにも反映し、ヘッダのバージョンコメントを更新する。

## トラブルシュート

- **skills が一覧に出ない** → 置き場所は `<プロジェクトルート>\.claude\skills\<name>\SKILL.md`。ディレクトリ名と frontmatter の `name:` の不一致、深すぎるネストを確認。
- **CLAUDE.md が重い気がする** → フル(lift+orchestrate+blueprint)で常駐約3.1K トークン。Sonnet 単独で走らせるプロジェクトでは Project specifics を最小限に保つ(lift README のモデル別チューニング参照)。
- **AGENTS.md と CLAUDE.md の内容が食い違う** → Project specifics の同期漏れが典型。正は CLAUDE.md 側とし、変更時に AGENTS.md へ転記する。

## コントリビュート

Issue・PR 歓迎です — バグ報告、翻訳の修正、テンプレートの改善、いずれも助かります。ファミリー自身の思想に合わせたハウスルールがいくつか:

- **ルールは実際に再発した失敗から足す。** テンプレへの追加提案には、それが防いだはずの失敗(「どの一文が欠けていたか」)を添えてください。思いつきの「良い習慣」は原則見送ります — 常駐ルール1つ=トークンコストのため。
- **削る提案も足す提案と同価値。** 「このルールは発火しない」という報告も立派なコントリビュートです。
- README は英日ペア(`README.md` / `README.ja.md`)で同期を保ち、テンプレートを変更したらファイル先頭のバージョンコメントを更新してください。

## ライセンス

MIT — [LICENSE](LICENSE) を参照。
