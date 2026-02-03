#!/bin/bash
# Setup script to configure API credentials

echo ""
echo "=== Backlog Wiki Downloader Starting ==="
echo ""

read -p "Backlog Space URL を入力してください (e.g., https://your-space.backlog.jp): " BACKLOG_BASE_URL
read -p "Backlog API Key を入力してください: " BACKLOG_API_KEY
read -p "Backlog Project Key を入力してください (e.g., MY_PROJECT): " BACKLOG_PROJECT_KEY

echo ""

# Validate BACKLOG_BASE_URL
if [[ -z "$BACKLOG_BASE_URL" ]]; then
    echo "エラー: Space URL が入力されていません"
    exit 1
fi

if [[ ! "$BACKLOG_BASE_URL" =~ ^https:// ]]; then
    echo "エラー: Space URL は https:// で始まる必要があります"
    exit 1
fi

# Remove trailing slash if present
BACKLOG_BASE_URL="${BACKLOG_BASE_URL%/}"

# Validate BACKLOG_API_KEY
if [[ -z "$BACKLOG_API_KEY" ]]; then
    echo "エラー: API Key が入力されていません"
    exit 1
fi

if [[ ${#BACKLOG_API_KEY} -lt 50 ]]; then
    echo "エラー: API Key が短すぎます"
    exit 1
fi

# Validate BACKLOG_PROJECT_KEY
if [[ -z "$BACKLOG_PROJECT_KEY" ]]; then
    echo "エラー: Project Key が入力されていません"
    exit 1
fi

if [[ ! "$BACKLOG_PROJECT_KEY" =~ ^[A-Z_]+$ ]]; then
    echo "エラー: Project Key は大文字とアンダースコア (_) のみ使用できます"
    exit 1
fi

export BACKLOG_BASE_URL
export BACKLOG_API_KEY
export BACKLOG_PROJECT_KEY

echo "✓ 変数が設定されました"
echo "  BACKLOG_BASE_URL: $BACKLOG_BASE_URL"
echo "  BACKLOG_API_KEY: ${BACKLOG_API_KEY:0:10}..."
echo "  BACKLOG_PROJECT_KEY: $BACKLOG_PROJECT_KEY"
echo ""
echo "-→ 次に以下を実行してください"
echo "./2_get-wiki-ids.sh"
echo ""
