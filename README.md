# Backlog Wiki ダウンローダー

Backlog の Wiki ページを API 経由でダウンロードし、Markdown 形式に変換するコマンドラインツールです。

## 機能

- Backlog プロジェクトから全 Wiki ページを一括ダウンロード
- Backlog Wiki 形式から Markdown への変換
- メタデータの保持（ID、プロジェクト ID、名前、更新日時）
- 進捗表示付きバッチ処理

## 必要な環境

- macOS または Linux
- bash または zsh
- `curl`（macOS に標準搭載）
- `jq` - インストール方法: `brew install jq` (macOS) または `apt-get install jq` (Linux)

## インストール

リポジトリをクローンします:
```bash
git clone https://github.com/tadokoro88/backlog-wiki-downloader.git
cd backlog-wiki-downloader
```

## 使い方

スクリプトを実行します:
```bash
./download.sh
```

以下の情報を入力してください:
- **Space URL**: Backlog スペースの URL（例: `https://your-space.backlog.jp`）
- **API Key**: Backlog の API キー（個人設定 > API から取得）
- **Project Key**: プロジェクト識別子（例: `MY_PROJECT`）

認証情報を入力すると、Wiki 一覧を取得して `wiki_list.csv` に保存します。
不要な Wiki がある場合は、別のターミナルで `wiki_list.csv` を編集してから Enter を押してください。
その後、JSON のダウンロードと Markdown への変換が自動で実行されます。

## 出力ファイル構造

ダウンロードしたファイルは `~/Downloads/backlog-wiki/` に保存されます:

```
~/Downloads/backlog-wiki/
└── YOUR_PROJECT_KEY/
    ├── wiki_list.csv
    ├── json/
    │   └── *.json
    └── md/
        └── *.md
```

## セキュリティに関する注意

- **API キーをバージョン管理にコミットしないでください**
- API キーはスクリプト実行中のみ使用され、保存されません
- ダウンロード前に `wiki_list.csv` を確認し、不要な Wiki の行は削除してください

## API レート制限について

Backlog API にはプランに応じたレート制限があります（詳細: https://developer.nulab.com/ja/docs/backlog/rate-limit/）

大量の Wiki をダウンロードする場合、レート制限に達する可能性があります。その場合は時間をおいて再実行してください。

## トラブルシューティング

**"command not found: jq" と表示される**
```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt-get install jq
```

**"Invalid API Key" エラー**
- Backlog の個人設定 > API で API キーを確認してください
- `./download.sh` を再実行して認証情報を入力し直してください

**"Project not found" エラー**
- プロジェクトへのアクセス権限があることを確認してください
- プロジェクトキーが正しいか確認してください（大文字とアンダースコア）

## ライセンス

MIT License - 自由に使用・改変できます。

## コントリビューション

Issue や Pull Request を歓迎します！
