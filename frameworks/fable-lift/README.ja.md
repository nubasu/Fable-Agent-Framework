# fable-lift

[English](README.md) | 日本語

Opus 4.8 / Sonnet 5 を、Fable 5 級の「仕事のやり方」に引き上げるコンテキストフレームワーク。

## 発想

モデル階層間の実務パフォーマンス差は、素の推論力の差だけではなく、大部分が**作業規律の差**として現れる:

- 検証せずに「できました」と報告する(実行していないコードを動くと言う)
- エラーで仮説なしに同じことをリトライする/失敗した修正の上にパッチを積み重ねる
- 存在しない API を呼ぶ、記憶で数値やパスを捏造する
- 長いタスクで前半の決定を忘れ、自己矛盾する
- 依頼の 3 項目中 2 項目だけやって完了と言う
- ユーザーの誤った診断にそのまま同調する

上位モデルはこれらを**暗黙の習慣**として回避している。fable-lift はその習慣を明文化し、**発火条件付きのプロトコル**として下位モデルに課すことで、この差を埋める。

### 正直な効能書き

- **上がるもの**: 検証規律、報告の正確さ、デバッグの体系性、スコープ管理、長期タスクの整合性 — 実務でのエージェント失敗の大半を占める領域。
- **上がらないもの**: 素の推論力・知識。新規性の高いアルゴリズム設計や微妙なアーキテクチャのトレードオフ判断は、依然として上位モデルが優る。重要な意思決定は上位モデルで行うこと(後述のハイブリッド運用)。

## 構成 — 2層アーキテクチャ

コンテキスト予算(常駐トークンはタスク文脈と競合する)を考慮し、常駐部を最小化した2層構成。

```
fable-lift/
├── CLAUDE.template.md              ← 常駐コア(約1.2Kトークン)。プロジェクト直下に CLAUDE.md として配置
└── .claude/skills/                 ← オンデマンド・プロトコル(発火時のみ読込、各約700トークン)
    ├── deep-plan/                  ← 着手前の設計:契約化・複数案比較・プレモーテム
    ├── root-cause-debug/           ← 根本原因デバッグ:仮説ジャーナル・弁別実験
    ├── finish-gate/                ← 完了ゲート:「done」と言う前の必須チェック(最重要)
    ├── long-task-state/            ← 外部作業記憶:コンパクション・セッション跨ぎ対策
    └── test-protocol/              ← テスト品質:fail-first・モック最小・境界とエラーパス必須(v1.1)
```

- **コア**は単体でも機能する(skills が発火しなくても行動は改善する)よう設計。
- **skills** はコア内の「発火条件テーブル」で明示的にトリガーされる。下位モデルは自発的なスキル選択が苦手なため、条件を機械的にした(「3ファイル以上→deep-plan」「完了宣言の直前→finish-gate」)。

## 導入手順(新規プロジェクト)

他フレームワークとの組み合わせ導入(推奨フルスタック等)は、ストア直下の README.ja.md を参照。

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks\fable-lift"   # ← この repo を置いた場所に合わせる
$proj    = "C:\path\to\new-project"

Copy-Item "$storage\CLAUDE.template.md" "$proj\CLAUDE.md"
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Fable-Agent-Framework/frameworks/fable-lift"   # ← この repo を置いた場所に合わせる
proj="/path/to/new-project"

cp "$storage/CLAUDE.template.md" "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

その後、新プロジェクトで:

1. `/init` を実行し、生成された内容を `CLAUDE.md` 末尾の **Project specifics** セクションにマージする(フレームワーク部分は残す)。
2. 既存プロジェクトに入れる場合は、コアの内容を既存 CLAUDE.md に**追記**し、`.claude/skills/` をコピーする。

## モデル別チューニング

- **Sonnet 5**: 指示追従の注意予算が小さい。コアの上にプロジェクト固有ルールを大量に足さないこと(Project specifics はコマンドと入口の列挙に留める)。ルール総量が増えるほど1ルールあたりの遵守率が下がる。
- **Opus 4.8**: ルール追加への耐性は高め。extended thinking / effort 設定を上げると deep-plan・root-cause-debug の効果が伸びる。
- **ハイブリッド運用(推奨)**: 設計判断(deep-plan の代替案比較)は Fable/上位モデルのセッションで行い、その計画を `long-task-state` のステートファイルに書き出して、実装は本フレームワーク入りの Sonnet で回す。計画の質を上位モデルで担保し、実行の規律を本フレームワークで担保する分業。

## 運用ルール(フレームワーク自体の育て方)

- **ルールは失敗から逆算して足す。** 実際に再発した失敗パターンにだけ対応ルールを追加する。1ルール=常駐コスト。思いつきの「良い習慣」を足さない。
- **発火しないルールは削る。** 数プロジェクト運用して一度も効いていないルールはコストでしかない。
- バージョンコメント(ファイル先頭)を更新し、変更理由を一行残す。

## なぜ中身が英語か

モデル向けファイル(コア・skills)はトークン効率と指示追従精度のため英語。ユーザーへの応答言語は「ユーザーの言語に追従する」ルールをコアに含めてあるため、日本語での対話品質には影響しない。README は人間向けのため、英語版(README.md)と日本語版(本ファイル)の両方を用意している。

## 関連フレームワーク

- `frameworks/fable-orchestrate/` — 本フレームワークが「自分の手を動かす規律」を担うのに対し、サブエージェント(Sonnet 5 / Codex)への指示出し・検収の規律を担う姉妹フレームワーク。リード役セッションには両方の導入を推奨。
- `frameworks/fable-blueprint/` — 仕様から設計・計画・チケットを起こす上流工程フレームワーク。本フレームワークの `deep-plan` は単一タスク向けの軽量版で、仕様一式から起こす場合は blueprint 側を使う。
- `frameworks/fable-team/` — ファミリー3部作の蒸留版をロール・ディスパッチ内蔵の1枚(AGENTS.md)に凝縮したチーム憲法。フル導入前の軽量スタートや、Codex を含むベンダー横断の統一に。
- `frameworks/fable-solo/` — 本フレームワークの skills をインライン化した単独 Opus 専用の1ファイル完結版(約3K常駐、発火リスクゼロ)。Sonnet も走らせるなら本フレームワーク、Opus 単独なら solo。
- `frameworks/fable-retro/` — セッション跨ぎの復元とルール育成の継続運用モジュール。本フレームワークの `long-task-state` が状態ファイルの「形式」を定めるのに対し、retro 側の `session-bootstrap` はそれを読み書きする「セッション開始・終了の儀式」を定める。併用推奨。

## 既知の限界と将来拡張

- テキストによる規律は強制力ではなく強い誘導。機械的強制(例: finish-gate 未実施の完了を Stop フックでブロック)はオプションの `frameworks/fable-harness/` として実装済み — フックスクリプトに OS 依存性が出るため本体とは分離してある。
- コンパクション後の遵守率は低下しうる。長期タスクでは long-task-state のステートファイルが実質的な保険になる。
