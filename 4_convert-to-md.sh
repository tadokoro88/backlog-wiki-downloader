#!/bin/bash
# Step 3: Convert Backlog wiki JSON files to Markdown

if [[ -z "$BACKLOG_PROJECT_KEY" ]]; then
    echo "エラー: BACKLOG_PROJECT_KEY を設定する必要があります。1_setup.sh を実行してください。"
    exit 1
fi

JSON_DIR="../${BACKLOG_PROJECT_KEY}/json"
MD_DIR="../${BACKLOG_PROJECT_KEY}/md"

if [[ ! -d "$JSON_DIR" ]]; then
    echo "エラー: $JSON_DIR が見つかりません。3_download-wikis.sh を実行してください。"
    exit 1
fi

mkdir -p "$MD_DIR"

for json_file in "$JSON_DIR"/*.json; do
    [ -e "$json_file" ] || continue
    
    basename=$(basename "$json_file" .json)
    md_file="${MD_DIR}/${basename}.md"
    
    echo "変換中 $basename..."
    
    content=$(jq -r '.content // ""' "$json_file")
    id=$(jq -r '.id' "$json_file")
    project_id=$(jq -r '.projectId' "$json_file")
    name=$(jq -r '.name' "$json_file")
    updated=$(jq -r '.updated' "$json_file")
    
    converted_content=$(echo "$content" | sed 's/\\r\\n/\n/g' | sed 's/^\* /# /')
    
    {
        echo "$converted_content"
        echo ""
        echo "---"
        echo ""
        echo "**Metadata:**"
        echo "- ID: $id"
        echo "- Project ID: $project_id"
        echo "- Name: $name"
        echo "- Updated: $updated"
    } > "$md_file"
done

echo ""
echo "マークダウン形式への変換が完了しました"
echo "保存先 → $MD_DIR"
echo ""
echo "=== Backlog Wiki Downloader Completed ==="
echo ""
