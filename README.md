# Backlog Wiki ダウンローダー

Backlog の Wiki ページを API 経由でダウンロードし、Markdown 形式に変換するコマンドラインツールです。

## 機能

- Backlog プロジェクトから全 Wiki ページを一括ダウンロード
- Backlog Wiki 形式から Markdown への変換
- メタデータの保持（ID、プロジェクト ID、名前、更新日時）
- 進捗表示付きバッチ処理

## 必要な環境

- macOS または Linux
- bash
- `curl`（macOS に標準搭載）
- `jq` - インストール方法: `brew install jq` (macOS) または `apt-get install jq` (Linux)

## インストール

リポジトリをクローンします:
```bash
git clone https://github.com/tadokoro88/backlog-wiki-downloader.git
cd backlog-wiki-downloader
```

## セットアップ

セットアップスクリプトを実行し、認証情報を入力します:
```bash
source 1_setup.sh
```

以下の情報を入力してください:
- **Space URL**: Backlog スペースの URL（例: `https://your-space.backlog.jp`）
- **API Key**: Backlog の API キー（個人設定 > API から取得）
- **Project Key**: プロジェクト識別子（例: `MY_PROJECT`）

## 使い方

`1_setup.sh` を実行後、以下のスクリプトを順番に実行します:

### Step 1: Wiki 一覧の取得
```bash
./2_get-wiki-ids.sh
```
すべての Wiki の ID とタイトルを含む `wiki_list.csv` を作成します。

### Step 2: Wiki JSON ファイルのダウンロード
```bash
./3_download-wikis.sh
```
すべての Wiki を JSON ファイルとして `../${PROJECT_KEY}/json/` にダウンロードします。

### Step 3: Markdown への変換
```bash
./4_convert-to-md.sh
```
JSON ファイルを Markdown 形式に変換し、`../${PROJECT_KEY}/md/` に保存します。

## 出力ファイル構造

```
backlog-wiki-downloader/
├── 1_setup.sh
├── 2_get-wiki-ids.sh
├── 3_download-wikis.sh
├── 4_convert-to-md.sh
├── wiki_list.csv（自動生成）
└── YOUR_PROJECT_KEY/
    ├── json/
    │   └── *.json
    └── md/
        └── *.md
```

## セキュリティに関する注意

- **API キーをバージョン管理にコミットしないでください**
- API キーはターミナルセッション中のみ環境変数に保存されます
- 新しいターミナルセッションでは `source 1_setup.sh` を再実行してください
- ダウンロード前に `wiki_list.csv` を確認し、不要な Wiki の行は削除してください

## API レート制限について

Backlog API にはプランに応じたレート制限があります（詳細: https://developer.nulab.com/ja/docs/backlog/rate-limit/）

現在のレート制限を確認するには:
```bash
curl -s "${BACKLOG_BASE_URL}/api/v2/rateLimit?apiKey=${BACKLOG_API_KEY}"
```

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
- `source 1_setup.sh` を再実行して認証情報をリセットしてください

**"Project not found" エラー**
- プロジェクトへのアクセス権限があることを確認してください
- プロジェクトキーが正しいか確認してください（大文字とアンダースコア）

## ライセンス

MIT License - 自由に使用・改変できます。

## コントリビューション

Issue や Pull Request を歓迎します！
