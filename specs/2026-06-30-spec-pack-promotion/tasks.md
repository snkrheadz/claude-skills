---
id: 2026-06-30-spec-pack-promotion
phase: tasks
status: ready
---

## 実装タスク

- [x] T1: `spec` パックの骨格を作る（plugin 定義・README・ルーブリック参照物）
  - 触る場所: `spec/.claude-plugin/plugin.json`（新規）、`spec/README.md`（新規）、`spec/skills/scan/<rubric 参照ファイル>`（新規）
  - 内容: `plugin.json` に name=spec / version=0.1.0 / description（Boris 哲学のパイプラインである旨）/ author / license。`README.md` は利用ガイド（全体フロー・各フェーズ・人間ゲート・利用例。laptop の specs/README.md を出自を明記して移植）。ルーブリックは scan が参照する持ち運び可能な3本柱の評価基準ファイル。
  - 検証:
    - `jq empty spec/.claude-plugin/plugin.json` が成功（valid JSON）。
    - `spec/README.md` と ルーブリック参照物が存在し、README から各フェーズが辿れる。
    - この時点で `bash scripts/validate.sh` が緑（spec は未登録のため既存カタログに影響なし）。
  - 由来: design「パック定義」「ルーブリックをパック内参照物に分離」/ AC「人間向けドキュメント同梱」

- [x] T2: 6フェーズを skill 形式へ移植（本文温存・frontmatter 変換・参照の名前空間整合）
  - 触る場所: `spec/skills/{scan,requirement,design,tasks,implement,review}/SKILL.md`（新規6本）
  - 内容: laptop の各コマンド本文を温存して移植。frontmatter を skill 規約へ（`name`=ディレクトリ名、`description` に `Triggers:` を含める、`user-invocable: true`、model は無指定＝main セッション）。本文中の内部参照を名前空間整合（`/spec-design`→`/spec:design`、`/spec-tasks`→`/spec:tasks`、`/spec-requirement`→`/spec:requirement`、`/spec-review`→`/spec:review`、`/implement-with-notes`→`/spec:implement`、`/eng:create-pr`・`/eng:test-and-fix` は維持）。scan はルーブリック参照物を指すよう調整。review 本文の独自用語は意味が通る最小の言い換え。
  - 検証:
    - 各 `SKILL.md` の frontmatter `name:` がディレクトリ名と一致、`description` に `Triggers:` を含み、`user-invocable: true`。
    - 本文の手順・ゲート停止文言が現行と同一（移植の忠実性）。grep で旧形式参照（`/spec-…`、`/implement-with-notes`）が残っていないこと。
    - 6本それぞれ単体で読んで、現行コマンドと同じフェーズ挙動が再現できる。
  - 由来: design「本文温存 frontmatter 変換」「実装を /spec:implement 同梱」「名前空間整合」/ AC「現行と同じ成果物＋ゲート」「内部参照が解決できる」

- [x] T3: カタログと repo README に `spec` を登録
  - 触る場所: `.claude-plugin/marketplace.json`（変更）、`README.md`（リポジトリ直下・変更）
  - 内容: marketplace.json の `plugins` 配列に spec エントリ追加（source=./spec、version は plugin.json と一致、description）。既存6パックは無変更。repo README のパック一覧に spec を追記。
  - 検証:
    - `jq empty .claude-plugin/marketplace.json` 成功。
    - spec エントリの version が `spec/.claude-plugin/plugin.json` と一致。
    - `git diff` で既存6パックのエントリが無変更。
  - 由来: design「カタログへ spec 追加」「既存パック無変更」/ AC「install で全フェーズ選択可能」「カタログ整合」

- [x] T4: closing gate（validate.sh）とインストール・スモークで受け入れ条件を観測
  - 触る場所: 検証専用（恒久変更なし）
  - 内容:
    - `bash scripts/validate.sh` を実行し、spec を含めて fail 0 で通る（model 無指定の WARN は許容）。`claude plugin validate .` が使えれば併用。
    - 可能なら spec パックを install して `/spec:scan` `/spec:requirement` 等が選択でき、現行と同じ成果物・人間ゲートで停止することを確認。少なくとも各 SKILL.md がカタログから選択可能な状態であることを確認。
    - 参照解決: パイプライン案内に現れる `/spec:implement`・`/eng:create-pr`・`/eng:test-and-fix` が install 済み環境で解決できることを確認。
    - 既存パックの install・利用が従来どおりであること（回帰なし）。
  - 検証: validate.sh fail 0、各フェーズ選択可能、参照切れなし、既存パック回帰なし。最終 `git status` がコミット対象のみ。
  - 由来: requirement「検証方法」全項 / AC 全条

## 実装順序の根拠
- T1 でパックの器（plugin.json/README/rubric）を用意 → T2 で中身（6 skill）を移植 → T3 でカタログ登録。**登録（T3）を最後に回す**ことで、未完成の skill が登録済みカタログに混入して validate を壊すのを防ぎ、各段でツリー（カタログ）を緑に保つ。
- T4 は全配置後に closing gate と install を実地観測する非破壊検証。

## 完了の定義（DoD）
- requirement.md「検証方法」全項が観測できる（install で全フェーズ動作／現行と同じ成果物＋ゲート／内部参照解決／validate 通過／ドキュメントで第三者理解／既存パック回帰なし）。
- `bash scripts/validate.sh` が fail 0（model WARN のみ許容）。`jq empty` が plugin.json/marketplace.json で成功。版整合。
- 差分が `spec/`（新規一式）・`.claude-plugin/marketplace.json`（spec 追加）・`README.md`（pack 一覧）に限定。既存6パックは無変更。
- 移植の忠実性: 各フェーズの手順・ゲート・altitude が現行と同一。旧形式参照の残存なし。
- 関係する教訓（CWD固定・単一情報源・名前空間整合）に反していない。
