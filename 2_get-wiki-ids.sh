#!/bin/bash
# Step 1: Get wiki IDs and titles from Backlog

if [[ -z "$BACKLOG_API_KEY" || -z "$BACKLOG_PROJECT_KEY" || -z "$BACKLOG_BASE_URL" ]]; then
    echo "エラー: BACKLOG_BASE_URL, BACKLOG_API_KEY, BACKLOG_PROJECT_KEY を設定する必要があります。1_setup.sh を実行してください。"
    exit 1
fi

BASE_URL="${BACKLOG_BASE_URL}/api/v2"
OUTPUT_FILE="wiki_list.csv"

echo "プロジェクトの Wiki 一覧を取得中: $BACKLOG_PROJECT_KEY"

response=$(curl -s "${BASE_URL}/wikis?apiKey=${BACKLOG_API_KEY}&projectIdOrKey=${BACKLOG_PROJECT_KEY}")

if ! echo "$response" | jq -e . >/dev/null 2>&1; then
    echo "エラー: Wiki 一覧の取得に失敗したか、無効な JSON 応答です"
    echo "応答内容: $response"
    echo ""
    echo "以下を確認してください:"
    echo "  - BACKLOG_API_KEY が正しいか (再度 'source 1_setup.sh' を実行してください)"
    echo "  - BACKLOG_PROJECT_KEY が正しいか"
    echo "  - プロジェクトへのアクセス権限があるか"
    exit 1
fi

if ! echo "$response" | jq -e 'type == "array"' >/dev/null 2>&1; then
    echo "エラー: 予期しない応答形式です (配列ではありません)"
    echo "応答内容: $response"
    echo ""
    echo "'source setup.sh' を再度実行して正しい認証情報を設定してください"
    exit 1
fi

echo "id,title" > "$OUTPUT_FILE"

if ! echo "$response" | jq -r '.[] | "\(.id),\(.name)"' >> "$OUTPUT_FILE" 2>/dev/null; then
    rm -f "$OUTPUT_FILE"
    echo "エラー: Wiki データの解析に失敗しました"
    exit 1
fi

count=$(tail -n +2 "$OUTPUT_FILE" | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
    rm -f "$OUTPUT_FILE"
    echo "エラー: プロジェクト $BACKLOG_PROJECT_KEY に Wiki が見つかりませんでした"
    exit 1
fi

echo "✓ ${count} 件の Wiki が見つかりました"
echo "✓ $OUTPUT_FILE に保存しました"
echo ""
echo "-→ $OUTPUT_FILE から不要な Wiki の行を削除してください"
echo "-→ 保存したら以下を実行してください"
echo "./3_download-wikis.sh"
echo ""
