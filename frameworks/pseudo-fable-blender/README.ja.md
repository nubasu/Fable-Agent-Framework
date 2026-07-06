# pseudo-fable-blender

[English](README.md) | 日本語 · 導入後の日常運用: [HOWTOUSE.ja.md](HOWTOUSE.ja.md)

Blender 3D モデリングの**ドメインパック** — **bpy スクリプト(ヘッドレス CLI)** または **Blender MCP** で Blender を操作するエージェントに、フルデプス・品質最優先の規律を注入する。意図的にトークン重量級: 目的は「最も安いセッション」ではなく「エージェントが物理的に作れる最高のモデル」。どの構成にも追加でき、Blender 専用リポジトリなら単体でも動く。非 Claude エージェントには AGENTS.md 追記版でパック全体を渡せる。常駐コア約1.8K トークン + オンデマンド skills 7種。

## 発想 — ここに diff レビューは存在しない。レンダーを見ることがレビューである

コーディングエージェントの検証本能はコード由来だ: 実行する、テストが通る、完了。3D モデリングはその本能をすべて裏切る — exit 0 のビルドスクリプトは何も証明せず、テストスイートは存在せず、真実の源は**レンダリング画像**と**メッシュデータ**の2つだけ。さらに、スペックに合格することと良い出来であることは別物で、エージェント製モデルの多くは正しさではなく品質で落ちる — 平板なライティング、単一スケールのディテール、プラスチックめいたマテリアル。パックはこの両層を攻める:

**正しさの失敗**(床):

1. **見ずに生成** — bpy を300行、exit 0、一度もレンダーせず成功報告。→「**見ていないモデルを信じない**」: 標準プローブ武器庫(4ビューリグ・クレイパス・ワイヤーフレームパス・データプローブ)+「誰も見ていないレンダーは何も検証していない」。
2. **プロポーションより先にディテール** — 比率が狂った胴体にベベルを盛る。→ ブロックアウト先行と**シルエットゲート**。
3. **シーンのエントロピー** — `Cube.001` の増殖、スケール未適用、レビュー不能なアウトライナー。→「**シーンはコードベースである**」: 実寸、意味のある命名、冪等な再ビルド。
4. **古い API の幻覚** — 2.8x 時代の学習データから bpy を想起(`use_auto_smooth` は 4.1 で消滅、EEVEE の id は 4.2 で変更)。→「**bpy は敵対的 API である**」: バージョンプローブ、名前参照、2度目の当て推量の前に `dir()`。

**品質の失敗**(天井 — このパックの存在理由):

5. **検証ごっこ** — 一瞥して「良さそう」で出荷。→ 固定順の批判的リーディング、**欠点名指しルール**、そして6軸**ルーブリック**(1–5、アンカー付き)を全ゲートで証拠つきで声に出して採点。
6. **最初の思いつきへの固着** — 最初のブロックアウトがそのまま最終形になる。→ hero ティアの**バリアント探索**: 比率解釈を変えた2〜3案を並べてレンダーし、理由を述べて選ぶ。
7. **単一スケールのディテール** — 素のプリミティブか一様なグリーブルか。どちらも CG に見える。→ **3スケール則**(primary/secondary/tertiary)+視線の重要度に従う密度。
8. **プラスチックなマテリアル** — 一様なラフネス、全彩度の色、metallic 0.5。→ PBR 数値規律(アルベド範囲、metallic は二値)と**リアリズムの主レバーとしてのラフネス変化**。
9. **プレゼンテーション盲** — デフォルトランプ、Standard ビュー変換、虚空に浮く被写体。→ カラーマネジメント最優先(AgX/Filmic)、スクリプト製3灯リグ、カメラと構図のルール。
10. **スペック合格で停止** — 基準は満たしたが、伸びしろが残っている。→「**スペック合格は完了ではない**」: **excellence ループ**がレンダーをシニアアーティストとして再批評し(パスごとに視点を交代)、指摘を実装する。hero では「2パス連続で cosmetic のみ」になるまで。

パックはスペック先行(`blender-spec` がジオメトリ前に「椅子を作って」を数値・アートディレクション・計測可能な完了基準へ変換)かつティア制 — **draft / production / hero、既定は hero**。このパックは「最高のものが欲しい」を前提にしている。

## 構成

```
pseudo-fable-blender/
├── BLENDER.template.md             ← 常駐コア(約1.8K): 鉄則・品質ティア・ルーブリック軸・トリガー。
│                                      プロジェクトの CLAUDE.md 末尾に追記
├── AGENTS.template.md              ← 外部エージェント(Codex 等)用の自己完結追記版:
│                                      7プロトコルすべてを凝縮。AGENTS.md に追記
├── settings.hooks.json             ← 任意のフック層: .claude/settings.json にマージする hooks ブロック
├── settings.hooks.powershell.json  ←   (Git Bash なしの Windows 向け PowerShell 変種)
├── .claude/hooks/
│   ├── stop-blender-qa.sh/.ps1     ← Stop フック: Blender 作業後のマーカーなし停止を弾く
│   └── posttool-blender-probe.sh/.ps1 ← headless 実行後のナッジ: レンダーを読め、PROBE 行を確認しろ
└── .claude/skills/
    ├── blender-spec/               ← 依頼 → アイデンティティ特徴・アートディレクション・ティア・寸法の数値・
    │                                  アーキタイプ比率表・計測可能な完了基準
    ├── blender-build-loop/         ← シーン契約 → ブロックアウト(hero はバリアント)+シルエットゲート →
    │                                  フォルム → 3スケールディテール。形状別戦略表と bpy バージョン規律
    ├── blender-topology/           ← 曲率で決める quad/n-gon 方針、SubD 制御、ブーリアン後始末、
    │                                  シェーディング工具箱、症状→原因表、エクスポート用トポロジー
    ├── blender-materials/          ← 実物に見える PBR 数値、ラフネス変化レシピ、防御的ノードスクリプティング、
    │                                  パレット規律、クレイ/ビューティ分離
    ├── blender-light-camera/       ← カラーマネジメント(AgX/Filmic)、スクリプト製3灯リグ、カメラと構図、
    │                                  用途別エンジン、プレゼンテーションセット
    ├── blender-scene/              ← カメラ先行レイアウト、スケールの真実、カメラ距離で刻む品質予算、
    │                                  インスタンス化と散布、動機のあるライティング
    └── blender-verify/             ← プローブ武器庫(4ビュー/クレイ/ワイヤ/ターンテーブル/クローズアップ/データ)、
                                       アンカー付きルーブリック、excellence ループ、最終 QA ゲート
```

## 品質マシナリー(「品質最優先」の具体形)

- **ティア** — draft / production / hero をスペックで宣言、既定 hero。ティアがルーブリックの下限(全6軸 ≥3 / ≥4)と成果物(hero: ターンテーブル・クローズアップ・カラーマネジメント済みビューティ)を決める。
- **ルーブリック** — 6軸(シルエットと比率 · トポロジーとシェーディング · ディテール · マテリアルのリアリズム · ライティングとプレゼンテーション · スペック忠実度)。2点と4点のアンカー記述つき、全ゲートで証拠と共に採点。軸の後退には理由の言明が要る。
- **excellence ループ** — 完了基準の合格後: 新規プローブ → 視点を交代しながらのシニアアーティスト批評(造形純粋主義者 / マテリアルオタク / フォトグラファー)→ 影響度順の指摘ちょうど5件・分類つき → cosmetic 以外は全実装 → 再採点。hero は「2パス連続 cosmetic のみ」まで抜けられない。
- **バリアント探索** — hero のブロックアウトはコミット前に比率解釈2〜3案を試す。最初の案が最良であることは稀で、それを知る最安の瞬間がここ。
- **プローブ武器庫** — `blender-verify` 同梱の冪等スニペット: 自動フレーミング4ビューリグ、クレイパス(マテリアルの雑音なしに形を見る)、ワイヤーフレームパス(トポロジーの可視化)、8ステップターンテーブル、85mm クローズアップ、`PROBE {json}` データプローブ(評価後 tris・寸法・非多様体・scale_applied)。

## 駆動モード

タスク開始時に宣言する。レシピは `blender-verify` に:

- **MCP** — ライブの Blender + MCP サーバー。screenshot/viewport ツールがレンダープローブを兼ね、コードプローブは execute-code で回す。名前による create-or-replace でライブシーンを冪等に保つ。
- **ヘッドレス CLI** — `blender --background --factory-startup --python-exit-code 1 --python build.py`。パラメータ化された正準ビルドスクリプト1本がバージョン管理下の成果物で、プローブレンダーは `renders/` に PNG 出力してエージェントが読む。(EEVEE はヘッドレスでも GPU/ディスプレイが要る。純サーバーでは形は Workbench、ビューティは Cycles CPU で。)

フルループはエージェントが画像を見られる前提(Claude Code は PNG を Read できる。MCP 構成の多くはスクリーンショットを返す)。画像を見られないエージェントはデータプローブ+人間がレンダーを読む形に退化する — パックはそれを装わず申告させる。

## 任意のフック層 — テキストでは閉じ切れない2つの失敗モードへの機械的ガードレール

pseudo-fable-harness と同じ思想(ガードレールが強制するのは儀式であって真実ではない)のドメイン特化版 — 汎用 harness はファイル編集しか見ておらず、bash や MCP 経由の Blender 作業を検知できない:

- **`stop-blender-qa`(Stop フック)** — セッションが Blender 作業(headless の `blender --background` 実行、`import bpy` を含む編集、`mcp__*blender*` ツール呼び出し)をしたのに、最後の作業以降に `[blender-qa: pass]` / `[blender-qa: n/a]` マーカーがなければ、QA 指示つきで停止を弾き返す。ループ安全(`stop_hook_active` を尊重、2回で諦める)、パース問題では fail open、tool_use を含む行だけを数える — bpy に言及しただけの文章では発火しない。
- **`posttool-blender-probe`(PostToolUse フック、matcher: Bash)** — headless の Blender 実行後にだけ発火:「`renders/` の新規画像をすべて Read して欠点を名指しせよ。PROBE 行を確認せよ」。意図的に headless 限定 — MCP のスクリーンショットは勝手にコンテキストに入るが、ディスク上の PNG は入らない。このフックはまさにその隙間のためにある。
- キルスイッチ: `PSEUDO_FABLE_BLENDER_DISABLE=qa,probe|all`(独自変数 — `PSEUDO_FABLE_HARNESS_*` からは独立)。
- pseudo-fable-harness と共存可: 両方の `hooks` ブロックを `.claude/settings.json` にマージする。各 Stop フックは独立に、最大2回まで弾く。導入後はセッションを再起動し `/hooks` で確認。

導入(任意。下の基本導入のあとに):

<details>
<summary>Windows (PowerShell)</summary>

```powershell
New-Item -ItemType Directory -Force "$proj\.claude\hooks" | Out-Null
Copy-Item -Force "$storage\.claude\hooks\*" "$proj\.claude\hooks\"
if (Test-Path "$proj\.claude\settings.json") { Write-Host "settings.json あり - hooks ブロックを手動でマージしてください" }
else { Copy-Item "$storage\settings.hooks.json" "$proj\.claude\settings.json" }
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
mkdir -p "$proj/.claude/hooks"
cp "$storage/.claude/hooks/"* "$proj/.claude/hooks/"
if [ -f "$proj/.claude/settings.json" ]; then echo "settings.json あり - hooks ブロックを手動でマージしてください"
else cp "$storage/settings.hooks.json" "$proj/.claude/settings.json"; fi
```

</details>

Windows では Git Bash があれば bash 変種のままで正しい。無い環境のみ `settings.hooks.powershell.json` を使う(pseudo-fable-harness と同じルール)。

## 他フレームワークとの接続

| 接続先 | 関係 |
|---|---|
| lift `finish-gate` | blender-verify の QA ゲートが Gate B/C 証拠のドメイン側を供給する。finish-gate の代替ではない |
| lift `root-cause-debug` | 一度の修正で直らないビルドスクリプトのバグ。シーン状態も証拠に数える |
| lift `long-task-state` | セッションを跨ぐビルドでスペック・フェーズ・ルーブリック履歴・チェックポイント一覧を保持 |
| orchestrate `delegate` | モデリングチケット=blender-spec の出力(数値+ティア+完了基準)を Contract に持つブリーフ |
| retro | 再発するシーンのミス(命名・スケール適用忘れ・クレイパス省略)を配置表経由でプロジェクトルール化 |

いずれも未導入で単体でも動く — ゲートはパック自身が持っている。

## 導入

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-blender"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\project"

# 1. 常駐コアを CLAUDE.md 末尾に追記
Get-Content "$storage\BLENDER.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. skills をコピー(7種、.claude/skills/ 配下に追加)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 3. 任意 — 外部エージェント(Codex 等): 追記版を AGENTS.md に追記
Get-Content "$storage\AGENTS.template.md" -Encoding utf8 | Add-Content "$proj\AGENTS.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-blender"   # ← この repo を置いた場所に合わせる
proj="/path/to/project"

cat "$storage/BLENDER.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"

# 任意 — 外部エージェント(Codex 等)
cat "$storage/AGENTS.template.md" >> "$proj/AGENTS.md"
```

</details>

AGENTS.md 追記版は、導入済みのベース(team か orchestrate 最小版)のどちらの AGENTS.md にも追記できる。外部エージェントのみで回す Blender 専用リポジトリなら、これ単体を AGENTS.md の本文にしてもよい。他フレームワークとの複合導入は repo ルートの README.ja.md を参照。

## 正直な限界

- テキスト規律は強い誘導であって強制ではない(ファミリー共通)。ゲートとルーブリックの効きはモデルの指示追従性能に比例する — ルーブリックのアンカーは自己採点の水増しを難しくするためにあり、不可能にはしない。
- スカルプト級の有機的表現はスクリプトモデリングの射程外のまま。パックの貢献は、それをスペック時点で申告させスタイライズ代替案を出させることであって、克服ではない。
- マテリアルとライティングの審美眼はエージェント駆動モデリングの最弱点。パックは収穫の大きいルール(ラフネス変化・カラーマネジメント・3灯の比率)を符号化しており床は大きく上がるが、アートディレクターの目の代替ではない。参照画像の提供は依然としてユーザーができる最良の一手。
- 同梱スニペットは 2.8x–4.x で安定してきた bpy API に絞っているが、Blender は動き続ける。本当の防御はスニペットの凍結ではなく規律そのもの(バージョンをプローブし、使う前に検証する)。
- 画像を見られないエージェントは検証ループの半分を失う(駆動モード参照)。
- hero ティアは本当に高くつく(数十レンダー、複数の excellence パス)。それは設計どおり — 不要なときは draft / production を指定する。
- フック層が検証するのは儀式(マーカーの存在、ナッジの発火)であって真実(レンダーが誠実に判定されたこと)ではない。偽の `[blender-qa: pass]` を刷るモデルには敗れる — だからマーカー契約はそれを鉄則違反と明記している。
