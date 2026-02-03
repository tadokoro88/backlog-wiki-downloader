#!/bin/bash
# Step 2: Download wiki JSON files

if [[ -z "$BACKLOG_API_KEY" || -z "$BACKLOG_PROJECT_KEY" || -z "$BACKLOG_BASE_URL" ]]; then
    echo "エラー: BACKLOG_BASE_URL, BACKLOG_API_KEY, BACKLOG_PROJECT_KEY を設定する必要があります。1_setup.sh を実行してください。"
    exit 1
fi

if [[ ! -f "wiki_list.csv" ]]; then
    echo "エラー: wiki_list.csv が見つかりません。2_get-wiki-ids.sh を実行してください。"
    exit 1
fi

BASE_URL="${BACKLOG_BASE_URL}/api/v2"
OUTPUT_DIR="../${BACKLOG_PROJECT_KEY}/json"

mkdir -p "$OUTPUT_DIR"

total=$(tail -n +2 wiki_list.csv | wc -l | tr -d ' ')
success=0
count=0

tail -n +2 wiki_list.csv | while IFS=, read -r wiki_id title; do
    ((count++))
    echo -n "[$count/$total] Wiki を取得しています $wiki_id... "
    
    response=$(curl -s "${BASE_URL}/wikis/${wiki_id}?apiKey=${BACKLOG_API_KEY}")
    
    if echo "$response" | jq -e . >/dev/null 2>&1; then
        safe_name=$(echo "$title" | sed 's/[<>:"/\\|?*]/_/g' | cut -c1-200)
        filename="${OUTPUT_DIR}/$(printf "%010d" $wiki_id)_${safe_name}.json"
        echo "$response" | jq . > "$filename"
        echo "✓ $title"
        ((success++))
    else
        echo "✗ 失敗"
    fi
done

echo "Wiki の保存が完了しました"
echo "保存先 → $OUTPUT_DIR"
echo ""
echo "-→ 次に以下を実行してください"
echo "./4_convert-to-md.sh"
echo ""
