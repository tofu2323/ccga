# デフォルトワークフローとカスタムワークフローの使い分けガイド

## `/init-github-app` で生成されるデフォルトワークフロー

### 1. claude.yml
- **用途**: @claude メンションへの応答
- **特徴**: シンプルで安定、公式サポート
- **いつ使う**: 基本的なコード生成、バグ修正、質問応答

### 2. claude-review.yml
- **用途**: PRの自動レビュー
- **特徴**: `direct_prompt`で自動実行（@claude不要）
- **いつ使う**: 全PRに対する一貫したレビュー

## カスタムワークフロー

### 1. claude-multi-agent.yml
- **用途**: 複雑なタスクの並列処理
- **特徴**: 最大16エージェントの同時実行
- **いつ使う**: 
  - 大規模リファクタリング
  - 新機能の包括的実装
  - 複数観点からの分析が必要な場合

### 2. claude-enhanced.yml
- **用途**: デフォルト機能 + マルチエージェントの統合版
- **特徴**: @claude と @claude-multi の両方に対応
- **いつ使う**: 柔軟性が必要な場合

## 推奨される組み合わせパターン

### パターン1: シンプル運用
```
- claude.yml（デフォルト）
- claude-review.yml（デフォルト）
```
単一エージェントで十分な小〜中規模プロジェクト向け。

### パターン2: ハイブリッド運用
```
- claude.yml（デフォルト）
- claude-review.yml（デフォルト）
- claude-multi-agent.yml（カスタム）
```
通常は単一エージェント、必要時のみマルチエージェント。

### パターン3: 統合運用
```
- claude-enhanced.yml（カスタム）
- claude-review.yml（デフォルト）
```
一つのワークフローで全機能をカバー。

## カスタマイズのポイント

### デフォルトワークフローの拡張
```yaml
# claude.yml に機能追加する例
- name: Run Claude Code
  uses: anthropics/claude-code-action@beta
  with:
    claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
    # カスタム設定追加
    allowed_tools: |
      Bash(npm test),
      Bash(npm run build),
      Bash(docker compose up)
    custom_instructions: |
      必ず日本語で応答してください
      テストを必ず作成してください
```

### トリガーフレーズのカスタマイズ
```yaml
# @claude 以外のトリガーを使う
trigger_phrase: "/ai"
# または
trigger_phrase: "!claude"
```

## 移行ガイド

既存のboilerplateワークフローからデフォルト＋カスタムへの移行：

1. `/init-github-app` を実行
2. 生成された claude.yml を確認
3. 必要に応じてカスタムワークフローを追加
4. 古いワークフローを段階的に削除

## トラブルシューティング

### Q: デフォルトとカスタムが競合する
A: ワークフローの `if` 条件を調整して、明確に区別する

### Q: どちらを使うべきか迷う
A: まずデフォルトで始めて、必要に応じてカスタムを追加

### Q: パフォーマンスの違いは？
A: デフォルトの方が起動が速い、マルチエージェントは並列処理で総合的に速い

## 実例：段階的な導入

### ステップ1: 基本機能から始める
```bash
# Claude Code で GitHub App をインストール
claude
/init-github-app
```

### ステップ2: 使ってみる
```markdown
# Issue や PR でテスト
@claude このコードをリファクタリングしてください
```

### ステップ3: 必要に応じて拡張
```bash
# マルチエージェント機能が必要になったら
cp .github/workflows/claude-multi-agent.yml.example .github/workflows/claude-multi-agent.yml
git add .github/workflows/claude-multi-agent.yml
git commit -m "feat: Add multi-agent workflow"
git push
```

### ステップ4: チームで活用
```markdown
# 複雑なタスクには @claude-multi を使用
@claude-multi 認証システム全体を実装してください

# 通常のタスクは @claude で
@claude このテストを修正してください
```

## ベストプラクティス

1. **段階的導入**: 最初はデフォルトから始める
2. **明確な使い分け**: トリガーフレーズで区別
3. **ドキュメント化**: チームでルールを共有
4. **定期的な見直し**: 使用状況を分析して最適化

## まとめ

- デフォルトワークフローは安定性重視
- カスタムワークフローは機能性重視
- プロジェクトの規模と要件に応じて選択
- 両方を組み合わせることも可能