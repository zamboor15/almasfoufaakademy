#!/bin/bash
# مزامنة فاضل_IDE.html — من المصدر الى الموقع
# المصدر: Codec Matrix/fdl_lang/فاضل_IDE.html
# الهدف: اكاديمية المصفوفة/downloads/فاضل_IDE.html + نشر Netlify

SOURCE="/mnt/drive_d/Codec Matrix/fdl_lang/فاضل_IDE.html"
TARGET="/mnt/drive_d/اكاديمية المصفوفة/downloads/فاضل_IDE.html"
SITE_DIR="/mnt/drive_d/اكاديمية المصفوفة"
FLAG_FILE="/tmp/fdl_ide_needs_update"

# --- الوظائف ---

check() {
    if [ ! -f "$SOURCE" ]; then
        echo "[خطأ] الملف المصدر غير موجود: $SOURCE"
        return 1
    fi

    # مقارنة MD5
    SRC_MD5=$(md5sum "$SOURCE" | cut -d' ' -f1)
    if [ -f "$TARGET" ]; then
        TGT_MD5=$(md5sum "$TARGET" | cut -d' ' -f1)
    else
        TGT_MD5="none"
    fi

    if [ "$SRC_MD5" = "$TGT_MD5" ]; then
        echo "[متزامن] لا يوجد تحديث — MD5: $SRC_MD5"
        rm -f "$FLAG_FILE"
        return 0
    else
        SRC_LINES=$(wc -l < "$SOURCE")
        TGT_LINES=0
        [ -f "$TARGET" ] && TGT_LINES=$(wc -l < "$TARGET")
        SRC_SIZE=$(du -h "$SOURCE" | cut -f1)

        echo "====================================="
        echo "  تحديث متاح لـ فاضل_IDE.html"
        echo "====================================="
        echo "  المصدر: $SRC_LINES سطر ($SRC_SIZE)"
        echo "  الموقع: $TGT_LINES سطر"
        echo "  MD5 المصدر: $SRC_MD5"
        echo "  MD5 الموقع: $TGT_MD5"
        echo "====================================="
        echo "  شغّل: sync_ide.sh deploy"
        echo "====================================="

        # كتابة علم للكرون
        echo "$SRC_MD5" > "$FLAG_FILE"

        # اشعار سطح المكتب
        if command -v notify-send &>/dev/null; then
            notify-send -u normal -i dialog-information \
                "تحديث فاضل IDE" \
                "تحديث متاح ($SRC_LINES سطر). شغّل: sync_ide.sh deploy"
        fi

        return 2
    fi
}

deploy() {
    echo "[نسخ] المصدر → الموقع..."
    cp "$SOURCE" "$TARGET"

    echo "[نشر] Netlify production..."
    cd "$SITE_DIR"
    netlify deploy --prod --dir=. --message "مزامنة تلقائية — فاضل_IDE.html $(date '+%Y-%m-%d %H:%M')" 2>&1 | tail -8

    rm -f "$FLAG_FILE"
    echo ""
    echo "[تم] الموقع محدّث: https://almasfoufaakademy.netlify.app"

    if command -v notify-send &>/dev/null; then
        notify-send -u normal -i dialog-information \
            "تم تحديث الموقع" \
            "فاضل_IDE.html نُشر على Netlify بنجاح"
    fi
}

status() {
    if [ -f "$FLAG_FILE" ]; then
        echo "[تنبيه] يوجد تحديث معلّق — شغّل: sync_ide.sh deploy"
    else
        echo "[متزامن] لا تحديثات معلّقة"
    fi
}

# --- التنفيذ ---

case "${1:-check}" in
    check)  check ;;
    deploy) check; [ $? -eq 2 ] && deploy || echo "[لا حاجة] الملفات متطابقة" ;;
    force)  deploy ;;
    status) status ;;
    *)
        echo "الاستخدام: sync_ide.sh [check|deploy|status|force]"
        echo "  check  — فحص وجود تحديث (افتراضي)"
        echo "  deploy — نسخ + نشر اذا يوجد تحديث"
        echo "  force  — نسخ + نشر بدون فحص"
        echo "  status — هل يوجد تحديث معلّق؟"
        ;;
esac
