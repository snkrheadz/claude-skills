---
id: 2026-06-30-spec-pack-promotion
phase: design
status: approved
---

> 注: マーケットプレイスへのパック追加（移植）。DDD/レイヤ語彙は該当範囲のみ honest に当てる。新規ロジックは作らず、既存コマンドを skill 形式へ移植して自己完結パック化する。

## ドメインモデル（DDD）
ユビキタス言語:
- **spec パック**: 監査→要件→設計→タスク→実装→レビューの一連フェーズと監査ルーブリックを束ねた、単体インストール可能な収録単位。
- **フェーズ skill**: 1フェーズ＝1 skill（`SKILL.md`）。`scan` / `requirement` / `design` / `tasks` / `implement` / `review` の6つ。各々スラッシュで起動し、自分のフェーズだけ実行して人間ゲートで止まる。
- **ルーブリック（rubric）**: 監査フェーズが使う3本柱（テスト自動化 / 検証ループ / 標準化・一貫性）の評価基準。パック同梱の持ち運べる参照物。
- **カタログ**: marketplace.json。パックの一覧と版を保持。`validate.sh` が整合性を検査する closing gate。
- **外部協調コマンド**: PR 作成・テスト修復など eng パックが担うもの。spec パックは重複収録せず、案内文から名前空間付きで参照する。

## レイヤ構成（クリーンアーキテクチャ）
依存方向「カタログ → パック → skill群 → ルーブリック参照」の一方向（外→内）。
- **infra / カタログ**: `.claude-plugin/marketplace.json` に `spec` パックのエントリを追加。`scripts/validate.sh` が検査。
- **パック定義**: `spec/.claude-plugin/plugin.json`（name=spec, version, description）と `spec/README.md`（人間向けガイド）。
- **interface-adapter / フェーズ skill**: `spec/skills/<phase>/SKILL.md`。現行コマンド本文を移植し、frontmatter を skill 規約へ。
- **参照物**: `spec/skills/scan/` 配下にルーブリックを置き、scan skill が参照（パック内で完結＝持ち運び可能）。
- 依存ルール: skill は eng パックの収録物を「案内（参照）」するのみで、取り込まない。逆依存なし。

## サービス境界 / 統合点
- 境界: **spec パック**（パイプライン本体＋実装＋ルーブリック、自己完結）と **eng パック**（create-pr / test-and-fix 等の周辺 workflow）。spec は eng に**機能を依存しない**（参照案内のみ）。昇格は移植であり既存パックの機能を奪わない（requirement 非機能要件）。
- 統合点: ①marketplace.json への spec エントリ追加、②各 skill の案内文に現れる他フェーズ・他パックへの参照（名前空間整合）、③`validate.sh` のカタログ検査。
- 名前空間: パック名 `spec` により各 skill は `/spec:scan` `/spec:requirement` `/spec:design` `/spec:tasks` `/spec:implement` `/spec:review` として解決される。

## 主要な設計判断
- 判断: **独立した `spec` パックを新設**（eng へ相乗りしない）/ 理由: 6フェーズ＋ルーブリックが一つの方法論として凝集し、単体で価値がある。eng（雑多な workflow 補完）とは性格が異なる / 却下案: eng に追加 → eng が肥大化し、方法論としての発見性が落ちる。
- 判断: **現行コマンド本文を温存し frontmatter のみ skill 規約へ変換**（`description` に `Triggers:` 追記、`user-invocable: true`、`argument-hint` は本文の入力説明へ吸収）/ 理由: requirement「移植の忠実性」。手順・ゲート・altitude を変えない / 却下案: 本文を書き直す → 振る舞いが変わるリスク。
- 判断: **実装フェーズ用コマンドを `/spec:implement` として同梱**（自己完結）/ 理由: requirement 確定事項「pack 同梱」。外部・個人 repo 依存を断つ / 却下案: 外部参照のまま → install しても参照切れ。
- 判断: **ルーブリックをパック内の参照ファイルに分離し scan が参照**/ 理由: requirement 確定「持ち運べる形」。監査基準を明示物として可搬化し、将来差し替えも容易 / 却下案: scan 本文に内包したまま → 持ち運びはできるが基準の明示性・再利用性が低い。
- 判断: **PR 作成・テスト修復は同梱せず eng 参照のまま**（案内文を `/eng:create-pr`・`/eng:test-and-fix` に整合）/ 理由: requirement「既存パックの機能を奪わない」「重複収録しない」/ 却下案: spec にも収録 → 二重管理・責務重複。
- 判断: **フェーズ skill は model 無指定（main セッション実行）**/ 理由: 要件・設計・レビューは判断の重いオーケストレーション（subagent 起動含む）で、セッションの主モデルで動くべき。`validate.sh` の model 検査は warn-only で「意図的な main-session skill は省略可」と明記 / 却下案: 弱いモデルに pin → 推論品質が落ちる。

## 既存コードへの影響（blast radius）
- **`spec/`（新規ディレクトリ一式）**: `.claude-plugin/plugin.json`、`README.md`、`skills/{scan,requirement,design,tasks,implement,review}/SKILL.md`、`skills/scan/<rubric 参照ファイル>`。
- **`.claude-plugin/marketplace.json`（変更）**: `plugins` 配列に `spec` エントリを追加（version は plugin.json と一致）。既存6パックのエントリは無変更。
- **移植元コマンド本文の参照書き換え（skill 化に伴う名前空間整合、移植時のみ）**:
  - scan: `/spec-requirement` → `/spec:requirement`
  - requirement: `/spec-design <id>` → `/spec:design <id>`
  - design: `/spec-tasks <id>` → `/spec:tasks <id>`
  - tasks: `/implement-with-notes …` → `/spec:implement …`、`/spec-review` → `/spec:review`（`/eng:create-pr`・`/eng:test-and-fix` は既に名前空間付きで維持）
  - review: `/eng:create-pr` 維持
- **`README.md`（リポジトリ直下・変更）**: パック一覧に spec を追記（既存パック README 慣習に合わせる）。
- **既存パック（core/pm/eng/research/strategy/writing）**: 無変更（追加のみ）。
- 破壊的変更なし。元の laptop リポジトリ側のローカルコピー削除・参照差し替えは **本件スコープ外**（昇格完了後の追従作業）。

## 受け入れ条件 → 設計 の対応表
| requirement の受け入れ条件 | それを満たす設計要素 |
| --- | --- |
| install で全フェーズが選択・実行可能 | `spec` パックに6フェーズ skill を収録、marketplace.json 登録 |
| 現行と同じ成果物＋人間ゲート挙動 | コマンド本文を温存して移植（frontmatter のみ変換） |
| 内部参照が install 後に解決できる | 実装コマンドを `/spec:implement` 同梱、他参照を名前空間整合（eng は参照案内） |
| カタログ整合性チェック通過 | plugin.json↔marketplace.json の版一致、SKILL.md に name/Triggers、`validate.sh` 通過 |
| 人間向けドキュメント同梱 | `spec/README.md`（利用ガイド）を収録 |

## リスク / 未確定
- **`validate.sh` の model 検査**: フェーズ skill は model 無指定とするため WARN が出る（fail ではない）。意図的 main-session skill である旨を README/コメントで明示し、WARN を許容する。実装時に validate を実走して fail が無いことを確認。
- **CI 不在**: claude-skills に CI workflow が無く、検証は手動 `validate.sh`。本件は手動 validate を closing gate とする（CI 整備は別案件）。
- **引数の受け渡し**: command の `argument-hint`/`$ARGUMENTS` が skill でも同様に機能するかを実装時に実起動で確認（`/spec:requirement "<intent>"`、`/spec:design <id>` 等）。
- **`公理2` 等の内部用語**: review コマンド本文が独自の公理番号を参照している。移植先で意味が通るよう、必要なら最小の言い換え（振る舞いは変えない）。
- **ドキュメントの出所明記**: パイプラインの出自（個人 dotfiles 由来）と Boris 哲学への言及は README に簡潔に残す（任意）。
- **スコープ外の追従**: 昇格後、laptop 側のローカル spec-* を pack install へ差し替える作業が別途必要（別案件）。
