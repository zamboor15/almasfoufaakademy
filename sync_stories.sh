#!/bin/bash
# سكربت مزامنة القصص — يُشغّل دورياً للكشف عن التحديثات
# Stories sync script — runs periodically to detect updates

SITE="/mnt/drive_d/اكاديمية المصفوفة"
SRC_MOZA="/mnt/drive_d/قصة اخوات موزة"
SRC_WRATH="/mnt/drive_d/قصة غضب الله الشديد"
DST_MOZA="$SITE/pages/stories/أخوات_موزة"
DST_WRATH="$SITE/pages/stories/غضب_الله_الشديد"
LOG="$SITE/.stories_sync.log"
HASH_FILE="$SITE/.stories_hash"

cd "$SITE" || exit 1

# Compute current hash of source files
current_hash=$(find "$SRC_MOZA" "$SRC_WRATH" -type f \( -name "*.md" -o -name "*.png" -o -name "*.jpg" \) -exec md5sum {} \; 2>/dev/null | sort | md5sum | awk '{print $1}')
prev_hash=$(cat "$HASH_FILE" 2>/dev/null || echo "")

if [ "$current_hash" = "$prev_hash" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No changes detected" >> "$LOG"
    exit 0
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Changes detected — syncing..." >> "$LOG"

# Sync all files (rsync-like via cp)
rsync -a --delete "$SRC_MOZA/" "$DST_MOZA/" 2>/dev/null || cp -r "$SRC_MOZA/." "$DST_MOZA/"
rsync -a --delete "$SRC_WRATH/" "$DST_WRATH/" 2>/dev/null || cp -r "$SRC_WRATH/." "$DST_WRATH/"

# Regenerate story HTML pages
python3 "$SITE/scripts/build_stories.py" >> "$LOG" 2>&1

# Save new hash
echo "$current_hash" > "$HASH_FILE"

# Auto-commit and push if there are git changes
if [ -n "$(git status --porcelain pages/stories/ pages/قصص.html 2>/dev/null)" ]; then
    git add pages/stories/ pages/قصص.html
    git commit -m "تحديث تلقائي للقصص — $(date '+%Y-%m-%d %H:%M')" 2>&1 | head -3 >> "$LOG"
    git push 2>&1 | tail -3 >> "$LOG"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pushed updates to GitHub" >> "$LOG"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No git changes after sync" >> "$LOG"
fi
