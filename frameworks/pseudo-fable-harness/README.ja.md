# pseudo-fable-harness

[English](README.md) | 日本語

強制モジュール — pseudo-fable の各 README は共通して「テキスト規律は強制力ではなく強い誘導」という限界を認めてきた。本モジュールはその欠けていた機械層を足す: 誘導が最も漏れやすい箇所を守る常時稼働の Claude Code hooks 3 本+ゴール直前にプロジェクトの実チェックを回すオプトインの **strict-verify** フック。どのフレームワーク構成にも追加できる。常駐コストは約 0.25K トークン(CLAUDE.md 追記分)で、フックスクリプト自体はコンテキスト外で動く。

## 発想 — 誘導からガードレールへ

よく誘導されたセッションでも生き残る失敗が 3 つある。いずれも注意が最も薄くなる瞬間 — ゴール直前・統合時・再起動時 — に起きるからだ:

1. **ゲートなしの「done」** — ファイルを編集したのに finish-gate を回さず完了報告する。→ **Stop フック**が、最後の編集の後に finish-gate マーカーが現れるまで停止をブロックする。
2. **サブエージェントの言葉のまま統合** — accept-work は存在するが、発火させる仕組みがない。→ **PostToolUse フック**が、サブエージェントが戻るたびに検収ナッジを注入する。
3. **記憶からの再開** — state ファイルはあるのに、新セッションがそれを読まない。→ **SessionStart フック**が、作業の最初のトークンより前に `.claude/state/` をコンテキストへ注入する。

### 正直な効能書き

- **強制できるもの: 儀式。** 編集の後には必ずゲートマーカーが要る・サブエージェントの後には必ずナッジが入る・state は必ずコンテキストにある。「忘れた」が不可能になる。
- **強制できないもの: 真実。** ゲートを正直に回さずに `[finish-gate: pass]` と印字することはできる — フックには見分けられない。価値は「黙った省略」を「能動的な嘘」に変換すること。嘘は非交渉ルール(と CLAUDE.md 追記)が文面で禁じている。
- **フェイルオープン設計。** フック内部のエラーはすべて「通す」に倒れる。ハーネスが作業を壊すことはあってはならない。

## 構成

```
pseudo-fable-harness/
├── HARNESS.template.md              ← CLAUDE.md 追記(約0.25K): マーカー契約
├── settings.hooks.json              ← hooks ブロック、bash コマンド(全 OS の既定 — 導入手順参照)
├── settings.hooks.powershell.json   ← Git Bash が無い Windows 向けの代替
└── .claude/hooks/                   ← フックスクリプト(各 .sh + .ps1 の対、ASCII のみ、依存ゼロ)
    ├── stop-finish-gate.(sh|ps1)        ← Stop: マーカーなしの「done」をブロック
    ├── stop-verify.(sh|ps1)             ← Stop、オプトイン strict モード: 実チェックを実行し失敗ならブロック
    ├── posttool-accept-work.(sh|ps1)    ← PostToolUse (Task|Agent): 検収ナッジ
    └── sessionstart-bootstrap.(sh|ps1)  ← SessionStart: .claude/state/ をコンテキスト注入
```

## フック一覧

| フック | 発火 | 挙動 | 強制対象 |
|---|---|---|---|
| `stop-finish-gate` | Stop(ターン終了) | セッションがファイルを変更(Write/Edit/MultiEdit/NotebookEdit)し、最後の編集の後に `[finish-gate: pass]` / `[finish-gate: n/a]` マーカーが無い → exit 2 で停止をブロックし、ゲート実行の指示をモデルに返す | lift `finish-gate` / solo §P3 |
| `stop-verify`(オプトイン) | Stop(ターン終了) | `PSEUDO_FABLE_HARNESS_VERIFY_CMD` 未設定なら何もしない。前回成功以降に編集があれば、プロジェクトルートでコマンドを実行し、失敗 → exit 2 で出力末尾つきで停止をブロック | finish-gate Gate B — 儀式ではなく*真実* |
| `posttool-accept-work` | PostToolUse、matcher `Task\|Agent` | サブエージェントの結果ごとに 1 行の検収ナッジを注入(非ブロック) | orchestrate `accept-work` |
| `sessionstart-bootstrap` | SessionStart(startup / resume / clear / compact) | `.claude/state/` にファイルがあれば一覧+最新 1 件の先頭(60 行 / 4KB 上限)をコンテキストへ注入。最新ファイルが 60 分より古ければ stale 警告を付す。無ければ無音 | retro `session-bootstrap` OPEN / lift `long-task-state` |

ブロック系フックのループ安全性: `stop_hook_active` があれば従い、それとは独立に「最後の編集以降すでに 2 回ブロック済みなら諦めて通す」を自前で持つ — 最悪でも各 2 回、無限ループにはならない。`stop-verify` はさらに「前回成功以降に変更がなければ実行しない」(セッション別スタンプを OS の temp に保存)。

## strict モードとランタイムスイッチ

**strict verify(オプトイン)。** `PSEUDO_FABLE_HARNESS_VERIFY_CMD` にプロジェクトの実チェックコマンドを設定する。置き場所は `.claude/settings.json` の `env` ブロックが最もきれい:

```json
{
  "env": { "PSEUDO_FABLE_HARNESS_VERIFY_CMD": "npm run typecheck && npm test -- --bail" }
}
```

編集があったターンの Stop 時にコマンドを実行し(bash 版は `sh -c`、PowerShell 版は `Invoke-Expression`、いずれもプロジェクトルートから。同梱 settings のタイムアウトは 300 秒)、失敗の間は完了をブロックして出力の末尾 1500 文字をモデルへ返す。ハーネス自身の最大の限界「儀式であって真実ではない」を Gate B について機械的に塞ぐ — マーカーは偽装できるが、落ちる typecheck は偽装できない。

**キルスイッチ。** `PSEUDO_FABLE_HARNESS_DISABLE` で settings.json を編集せずにフックを黙らせられる — `stop` / `accept` / `session` / `verify` / `all` のカンマ区切り(例: `PSEUDO_FABLE_HARNESS_DISABLE=accept,verify`)。

## 導入手順

Windows の Claude Code はフックコマンドを **Git Bash があれば Git Bash** で実行する(無ければ PowerShell)。つまり下の bash 構成が macOS / Linux **と**大半の Windows でそのまま正解。`settings.hooks.powershell.json` は Git Bash が無い環境でだけ使う。

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks\pseudo-fable-harness"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. フックスクリプトをコピー
New-Item -ItemType Directory -Force "$proj\.claude\hooks" | Out-Null
Copy-Item -Force "$storage\.claude\hooks\*" "$proj\.claude\hooks\"

# 2. hooks を登録(settings.json が無ければコピー、あれば "hooks" ブロックを手動マージ)
if (Test-Path "$proj\.claude\settings.json") { Write-Host "settings.json あり - hooks ブロックを手動でマージしてください" }
else { Copy-Item "$storage\settings.hooks.json" "$proj\.claude\settings.json" }

# 3. マーカー契約を CLAUDE.md に追記
Get-Content "$storage\HARNESS.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks/pseudo-fable-harness"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

mkdir -p "$proj/.claude/hooks"
cp "$storage/.claude/hooks/"* "$proj/.claude/hooks/"
if [ -f "$proj/.claude/settings.json" ]; then echo "settings.json あり - hooks ブロックを手動でマージしてください"
else cp "$storage/settings.hooks.json" "$proj/.claude/settings.json"; fi
cat "$storage/HARNESS.template.md" >> "$proj/CLAUDE.md"
```

</details>

その後: **セッションを再起動**し(フック登録は起動時に読み込まれる)、`/hooks` でハーネスの 4 本が一覧に出ることを確認する(`stop-verify` は `PSEUDO_FABLE_HARNESS_VERIFY_CMD` を設定するまで何もしない)。動作確認: 適当なファイルを 1 箇所編集し、完了報告なしでターンを終えてみる — 停止が 1 回だけ弾かれてゲート実行の指示が返ってくれば正常。

## 設計メモ

- **トランスクリプト検出はヒューリスティック。** Stop フックはセッションのトランスクリプト(JSONL)を部分文字列で走査する: サイドチェーンでない assistant エントリのファイルツール使用とマーカー。トランスクリプトのスキーマは公式に文書化されておらず、パターンは現行 Claude Code の実測フォーマットに合わせてある。フォーマットが変わった場合はフェイルオープン(通す)。
- **`.ps1` は意図的に ASCII のみ。** Windows PowerShell 5.1 は BOM なしスクリプトを ANSI として読むため、非 ASCII 文字は非英語 Windows で文字化けする。編集時も ASCII を保つこと。
- **マーカー契約**: ゲート通過後は `[finish-gate: pass]`、完了報告ではない停止(ブロック中・ユーザー入力待ち・非コーディングターン)は 1 行の理由 + `[finish-gate: n/a]`。HARNESS.template.md で定義し、ブロックメッセージ内でも繰り返しているため、追記なしでも Stop フック単体で機能する。

## 正直な限界

- **儀式であって真実ではない** — 偽のマーカーはフックを通る(上の効能書き参照)。正直さは機械ではなく文面の非交渉ルールが担う。
- シェルコマンド経由のファイル変更(Bash ツールでの `sed`・`git apply`・スクリプト実行)は編集として検出されない — ゲートが見るのはファイルツールだけ。シェル編集が常態のプロジェクトではパターンを拡張する(ノイズ増と引き換え)。
- 検収ナッジは読み取り専用の scout エージェントにも発火する — メッセージ側で「統合物がなければ流してよい」と書いてあるが、1 行のノイズは残る。邪魔なら settings から PostToolUse ブロックを削除する。
- マーカーは assistant エントリ内のどこにあってもカウントされる — モデルがマーカーを*引用*しただけ(extended thinking 内も含む)でもチェックは満たされてしまう。
- `stop_hook_active` は現行の hooks ドキュメントに記載がない。実効的なループ保護は自前の「2 回でやめる」制限。
- hooks は settings の全レベルでマージされる(ユーザー + プロジェクト両方が走る)。登録変更にはセッション再起動が必要。
- strict verify は任意のコマンドをシェル権限で実行する — `PSEUDO_FABLE_HARNESS_VERIFY_CMD` はビルドスクリプトと同じ扱いで、有効化前に中身を確認すること。PowerShell 版は `Invoke-Expression` 経由なので、素朴なネイティブコマンドを推奨。
- 2 本の Stop フックは独立に走る。両方がブロックした場合は両方のメッセージが届き、順序は保証されない。

## 育て方

- ファミリー共通: **再発した失敗から足し、発火しないものは削る。** シェル経由の編集がゲートをすり抜け続けるなら Bash 検出を足す。accept-work ナッジが行動を変えていないなら、そのブロックを削除する。
- ブロック/ナッジの文言はスクリプト内にある — CLAUDE.md のルールと同じ感覚で文言をチューニングし、`.sh` / `.ps1` の対を同期させること。
