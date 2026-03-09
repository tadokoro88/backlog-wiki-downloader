#!/bin/bash
# Backlog Wiki Downloader
# Downloads all wiki pages from a Backlog project and converts them to Markdown.

set -euo pipefail

echo ""
echo "=== Backlog Wiki Downloader ==="
echo ""

# -------------------------------------------------------
# Step 1: Setup - prompt for credentials
# -------------------------------------------------------

printf "Backlog Space URL を入力してください (e.g., https://your-space.backlog.jp): "
read BACKLOG_BASE_URL
printf "Backlog API Key を入力してください: "
read BACKLOG_API_KEY
printf "Backlog Project Key を入力してください (e.g., MY_PROJECT): "
read BACKLOG_PROJECT_KEY

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

echo "✓ 認証情報を確認しました"
echo "  BACKLOG_BASE_URL: $BACKLOG_BASE_URL"
echo "  BACKLOG_API_KEY: ${BACKLOG_API_KEY:0:10}..."
echo "  BACKLOG_PROJECT_KEY: $BACKLOG_PROJECT_KEY"
echo ""

BASE_URL="${BACKLOG_BASE_URL}/api/v2"
OUTPUT_BASE=~/Downloads/backlog-wiki/${BACKLOG_PROJECT_KEY}
JSON_DIR="${OUTPUT_BASE}/json"
MD_DIR="${OUTPUT_BASE}/md"
WIKI_LIST="${OUTPUT_BASE}/wiki_list.csv"

mkdir -p "$JSON_DIR" "$MD_DIR"

# -------------------------------------------------------
# Step 2: Fetch wiki list
# -------------------------------------------------------

echo "プロジェクトの Wiki 一覧を取得中: $BACKLOG_PROJECT_KEY"

response=$(curl -s "${BASE_URL}/wikis?apiKey=${BACKLOG_API_KEY}&projectIdOrKey=${BACKLOG_PROJECT_KEY}")

if ! echo "$response" | jq -e . >/dev/null 2>&1; then
    echo "エラー: Wiki 一覧の取得に失敗したか、無効な JSON 応答です"
    echo "応答内容: $response"
    echo ""
    echo "以下を確認してください:"
    echo "  - BACKLOG_API_KEY が正しいか"
    echo "  - BACKLOG_PROJECT_KEY が正しいか"
    echo "  - プロジェクトへのアクセス権限があるか"
    exit 1
fi

if ! echo "$response" | jq -e 'type == "array"' >/dev/null 2>&1; then
    echo "エラー: 予期しない応答形式です (配列ではありません)"
    echo "応答内容: $response"
    exit 1
fi

echo "id,title" > "$WIKI_LIST"

if ! echo "$response" | jq -r '.[] | "\(.id),\(.name)"' >> "$WIKI_LIST" 2>/dev/null; then
    rm -f "$WIKI_LIST"
    echo "エラー: Wiki データの解析に失敗しました"
    exit 1
fi

count=$(tail -n +2 "$WIKI_LIST" | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
    rm -f "$WIKI_LIST"
    echo "エラー: プロジェクト $BACKLOG_PROJECT_KEY に Wiki が見つかりませんでした"
    exit 1
fi

echo "✓ ${count} 件の Wiki が見つかりました"
echo "✓ $WIKI_LIST に保存しました"
echo ""
echo "不要な Wiki がある場合は、別のターミナルで $WIKI_LIST を編集してください。"
printf "準備ができたら Enter を押してください..."
read

echo ""

download_count=$(tail -n +2 "$WIKI_LIST" | wc -l | tr -d ' ')
printf "${download_count} 件の Wiki をダウンロードしてよろしいですか？(Y/n): "
read confirm
if [[ "$confirm" =~ ^[nN] ]]; then
    echo "中止しました"
    exit 0
fi

echo ""

# -------------------------------------------------------
# Step 3: Download wiki JSON files
# -------------------------------------------------------

total=$(tail -n +2 "$WIKI_LIST" | wc -l | tr -d ' ')
success=0
download_count=0

echo "Wiki のダウンロードを開始します ($total 件)"
echo ""

tail -n +2 "$WIKI_LIST" | while IFS=, read -r wiki_id title; do
    ((download_count++))
    echo -n "[$download_count/$total] Wiki を取得しています $wiki_id... "

    response=$(curl -s "${BASE_URL}/wikis/${wiki_id}?apiKey=${BACKLOG_API_KEY}")

    if echo "$response" | jq -e . >/dev/null 2>&1; then
        safe_name=$(echo "$title" | sed 's/[<>:"/\\|?*]/_/g' | cut -c1-200)
        filename="${JSON_DIR}/$(printf "%010d" $wiki_id)_${safe_name}.json"
        echo "$response" | jq . > "$filename"
        echo "✓ $title"
        ((success++))
    else
        echo "✗ 失敗"
    fi
done

echo ""
echo "✓ JSON ダウンロード完了 → $JSON_DIR"
echo ""

# -------------------------------------------------------
# Step 4: Convert JSON to Markdown
# -------------------------------------------------------

echo "Markdown への変換を開始します"
echo ""

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
echo "✓ Markdown 変換完了 → $MD_DIR"
echo ""
echo "=== Backlog Wiki Downloader Completed ==="
echo ""
