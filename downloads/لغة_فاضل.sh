#!/bin/bash
# ═══════════════════════════════════════════════════════════
# لغة فاضل — مثبّت شامل (لينكس / ماك)
# §FDL§ CODEC COSMIC OS — م. فاضل عباس الجعيفري
#
# ملف واحد يثبّت كل شيء:
#   • المترجم (fdl)
#   • بيئة التطوير (IDE)
#   • الأيقونة + اختصار سطح المكتب
#   • الأمثلة + المنهاج
#   • نظام التحديث التلقائي
#
# الاستخدام:
#   chmod +x لغة_فاضل.sh
#   ./لغة_فاضل.sh
# ═══════════════════════════════════════════════════════════

set -e
VERSION="2.0.0"
DIR="$(cd "$(dirname "$0")" && pwd)"

# === الألوان ===
GOLD='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
DIM='\033[2m'
NC='\033[0m'

# === الشعار ===
show_banner() {
    echo ""
    echo -e "${GOLD}    ╔═══════════════════════════════════════════╗${NC}"
    echo -e "${GOLD}    ║                                           ║${NC}"
    echo -e "${GOLD}    ║          ف                                ║${NC}"
    echo -e "${GOLD}    ║         ╱ ╲     §FDL§ لغة فاضل           ║${NC}"
    echo -e "${GOLD}    ║        │   │    v${VERSION}                    ║${NC}"
    echo -e "${GOLD}    ║         ╰─╮                               ║${NC}"
    echo -e "${GOLD}    ║                                           ║${NC}"
    echo -e "${BLUE}    ║     CODEC COSMIC OS                       ║${NC}"
    echo -e "${BLUE}    ║     م. فاضل عباس الجعيفري                 ║${NC}"
    echo -e "${GOLD}    ║                                           ║${NC}"
    echo -e "${GOLD}    ╚═══════════════════════════════════════════╝${NC}"
    echo ""
}

show_banner

# === كشف النظام ===
OS="unknown"
ARCH="$(uname -m)"
case "$(uname -s)" in
    Linux*)   OS="linux";;
    Darwin*)  OS="macos";;
    CYGWIN*|MINGW*|MSYS*) OS="windows";;
esac

echo -e "${CYAN}النظام:${NC} $OS ($ARCH)"

# === مسارات التثبيت ===
FDL_HOME="/usr/share/fdl"
BIN_DIR="/usr/local/bin"
NEEDS_SUDO=false

# فحص الصلاحيات
if [ ! -w "$FDL_HOME" ] 2>/dev/null || [ ! -w "$BIN_DIR" ] 2>/dev/null; then
    NEEDS_SUDO=true
fi

# مسارات بديلة بدون sudo
if [ "$NEEDS_SUDO" = true ] && [ -z "$SUDO_USER" ] && ! command -v sudo &>/dev/null; then
    FDL_HOME="$HOME/.fdl"
    BIN_DIR="$HOME/.local/bin"
    NEEDS_SUDO=false
fi

SUDO=""
if [ "$NEEDS_SUDO" = true ]; then
    echo -e "${DIM}يحتاج صلاحيات مدير النظام للتثبيت في ${FDL_HOME}${NC}"
    SUDO="sudo"
fi

echo -e "${CYAN}مسار التثبيت:${NC} $FDL_HOME"
echo -e "${CYAN}مسار الأوامر:${NC} $BIN_DIR"
echo ""

# ═══════════════════════════════════════════════════
# 1. إنشاء المجلدات
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[1/7]${NC} إنشاء المجلدات..."
$SUDO mkdir -p "$FDL_HOME"
$SUDO mkdir -p "$FDL_HOME/examples"
$SUDO mkdir -p "$FDL_HOME/extensions"
$SUDO mkdir -p "$FDL_HOME/updates"
$SUDO mkdir -p "$FDL_HOME/icons"
mkdir -p "$BIN_DIR" 2>/dev/null || $SUDO mkdir -p "$BIN_DIR"
echo -e "    ${GREEN}✓${NC} المجلدات جاهزة"

# ═══════════════════════════════════════════════════
# 2. الأيقونة
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[2/7]${NC} تثبيت الأيقونة..."

# إنشاء الأيقونة SVG مضمّنة (لا تحتاج ملف خارجي)
$SUDO tee "$FDL_HOME/icons/fdl.svg" > /dev/null << 'ICON_SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0a1628"/>
      <stop offset="40%" stop-color="#0c2040"/>
      <stop offset="100%" stop-color="#081830"/>
    </linearGradient>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#ffe066"/>
      <stop offset="40%" stop-color="#ffc830"/>
      <stop offset="100%" stop-color="#c89020"/>
    </linearGradient>
    <linearGradient id="teal" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#40c8e8"/>
      <stop offset="100%" stop-color="#2090c0"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.5" cy="0.45" r="0.45">
      <stop offset="0%" stop-color="#1a4a7a" stop-opacity="0.4"/>
      <stop offset="100%" stop-color="#0a1628" stop-opacity="0"/>
    </radialGradient>
    <filter id="textGlow">
      <feGaussianBlur stdDeviation="6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <rect x="8" y="8" width="496" height="496" rx="80" fill="url(#bg)"/>
  <rect x="8" y="8" width="496" height="496" rx="80" fill="url(#glow)"/>
  <rect x="18" y="18" width="476" height="476" rx="72" fill="none" stroke="#1a6090" stroke-width="1.2" opacity="0.3"/>
  <text x="256" y="310" text-anchor="middle" font-family="Tajawal,Noto Sans Arabic,Tahoma,Arial,sans-serif" font-weight="800" font-size="190" fill="url(#gold)" filter="url(#textGlow)" direction="rtl" letter-spacing="8">فاضل</text>
  <line x1="90" y1="360" x2="422" y2="360" stroke="url(#gold)" stroke-width="2" opacity="0.4"/>
  <text x="210" y="420" font-family="JetBrains Mono,Consolas,monospace" font-size="36" font-weight="700" fill="url(#teal)" opacity="0.75" letter-spacing="3">§FDL§</text>
  <text x="340" y="420" font-family="JetBrains Mono,Consolas,monospace" font-size="18" fill="url(#teal)" opacity="0.4">v2.0</text>
</svg>
ICON_SVG

# أيقونات بأحجام مختلفة للنظام (إذا وُجد ImageMagick أو rsvg-convert)
if command -v rsvg-convert &>/dev/null; then
    for SIZE in 16 32 48 64 128 256; do
        $SUDO rsvg-convert -w $SIZE -h $SIZE "$FDL_HOME/icons/fdl.svg" > "/tmp/fdl_${SIZE}.png" 2>/dev/null
        $SUDO mv "/tmp/fdl_${SIZE}.png" "$FDL_HOME/icons/fdl_${SIZE}.png" 2>/dev/null
    done
    echo -e "    ${GREEN}✓${NC} أيقونات PNG (6 أحجام)"
elif command -v convert &>/dev/null; then
    for SIZE in 16 32 48 64 128 256; do
        $SUDO convert -background none -resize ${SIZE}x${SIZE} "$FDL_HOME/icons/fdl.svg" "$FDL_HOME/icons/fdl_${SIZE}.png" 2>/dev/null
    done
    echo -e "    ${GREEN}✓${NC} أيقونات PNG (6 أحجام)"
else
    echo -e "    ${GREEN}✓${NC} أيقونة SVG (ثبّت librsvg2-bin لأيقونات PNG)"
fi

# تثبيت في مسارات النظام (لينكس)
if [ "$OS" = "linux" ]; then
    for SIZE in 16 32 48 64 128 256; do
        ICON_DIR="$HOME/.local/share/icons/hicolor/${SIZE}x${SIZE}/apps"
        mkdir -p "$ICON_DIR" 2>/dev/null
        if [ -f "$FDL_HOME/icons/fdl_${SIZE}.png" ]; then
            cp "$FDL_HOME/icons/fdl_${SIZE}.png" "$ICON_DIR/fdl.png" 2>/dev/null
        fi
    done
    # SVG scalable
    mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps" 2>/dev/null
    cp "$FDL_HOME/icons/fdl.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/fdl.svg" 2>/dev/null
    gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
fi

echo -e "    ${GREEN}✓${NC} الأيقونة مثبّتة"

# ═══════════════════════════════════════════════════
# 3. المترجم
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[3/7]${NC} تثبيت المترجم..."

# نسخ المترجم الثنائي (إذا موجود)
if [ -f "$DIR/المترجم.bin" ]; then
    $SUDO cp "$DIR/المترجم.bin" "$FDL_HOME/المترجم"
    $SUDO chmod +x "$FDL_HOME/المترجم"
    echo -e "    ${GREEN}✓${NC} المترجم: $(stat -c%s "$DIR/المترجم.bin") بايت"
elif [ -f "$FDL_HOME/المترجم" ]; then
    echo -e "    ${GREEN}✓${NC} المترجم موجود مسبقاً: $(stat -c%s "$FDL_HOME/المترجم") بايت"
else
    echo -e "    ${DIM}المترجم سيُثبّت لاحقاً${NC}"
fi

# المحمّل
if [ -f "$DIR/boot64.bin" ]; then
    $SUDO cp "$DIR/boot64.bin" "$FDL_HOME/"
fi
if [ -f "$DIR/boot64.asm" ]; then
    $SUDO cp "$DIR/boot64.asm" "$FDL_HOME/"
fi

# أمر fdl الموحّد
$SUDO tee "$BIN_DIR/fdl" > /dev/null << 'FDL_CMD'
#!/bin/bash
# ═══════════════════════════════════════════════════
# fdl — مترجم لغة فاضل
# §FDL§ CODEC COSMIC OS — م. فاضل عباس الجعيفري
# ═══════════════════════════════════════════════════

FDL_HOME="/usr/share/fdl"
# مسار بديل
[ -d "$HOME/.fdl" ] && [ ! -d "$FDL_HOME" ] && FDL_HOME="$HOME/.fdl"

COMPILER="${FDL_HOME}/المترجم"
VERSION="2.0.0"

GOLD='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'

show_version() {
    echo -e "${GOLD}═══════════════════════════════════════${NC}"
    echo -e "${GOLD}  لغة فاضل — FDL Language v${VERSION}${NC}"
    echo -e "${BLUE}  §FDL§ CODEC COSMIC OS${NC}"
    echo -e "${BLUE}  م. فاضل عباس الجعيفري${NC}"
    echo -e "${GOLD}═══════════════════════════════════════${NC}"
}

show_help() {
    show_version
    echo ""
    echo -e "${GREEN}الاستخدام:${NC}"
    echo "  fdl <ملف.فضل>              ترجمة وتشغيل"
    echo "  fdl <ملف.فضل> -o <ناتج>    ترجمة الى ملف تنفيذي"
    echo "  fdl --asm <ملف.فضل>         اظهار كود التجميع"
    echo "  fdl --ide                   فتح بيئة التطوير"
    echo "  fdl --update                فحص التحديثات"
    echo "  fdl --version               اصدار المترجم"
    echo "  fdl --help                  هذه المساعدة"
    echo ""
    echo -e "${GREEN}الصيغة:${NC}"
    echo "  *.فضل    ملفات لغة فاضل"
    echo "  *.fdl     ملفات لغة فاضل (بديل)"
    echo ""
    echo -e "${GREEN}الاوزان الصرفية:${NC}"
    echo "  :1  فَعَلَ    دالة         :7  فِعَالَة   صنف"
    echo "  :5  فَاعِل   كائن         :9  فُعْلَة    معامل"
    echo "  :6  مَفْعُول  متغير        :10 مِفْعَال   قاموس"
    echo "  :8  تَفْعِيل  ارجاع        :15 فُعُول    قائمة"
    echo ""
    echo -e "${GREEN}ادوات الشرط:${NC}"
    echo "  إنْ  إذا  لو  كلما  متى  مَنْ  ما  أينما"
    echo ""
}

# بدون وسائط
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    --version|-v)
        show_version
        exit 0
        ;;
    --help|-h)
        show_help
        exit 0
        ;;
    --ide)
        IDE="${FDL_HOME}/فاضل_IDE.html"
        if [ ! -f "$IDE" ]; then
            echo -e "${RED}خطأ: بيئة التطوير غير مثبتة${NC}"
            exit 1
        fi
        echo -e "${GOLD}§FDL§ — فتح بيئة التطوير...${NC}"
        if command -v xdg-open &>/dev/null; then xdg-open "$IDE"
        elif command -v open &>/dev/null; then open "$IDE"
        else echo "افتح: $IDE"; fi
        exit 0
        ;;
    --update)
        bash "${FDL_HOME}/updates/check_update.sh" 2>/dev/null || echo "نظام التحديث غير مثبّت"
        exit 0
        ;;
esac

# ترجمة ملف
SOURCE="$1"
if [ ! -f "$SOURCE" ]; then
    echo -e "${RED}خطأ: الملف غير موجود: ${SOURCE}${NC}"
    exit 1
fi

shift
OUTPUT=""
SHOW_ASM=false

while [ $# -gt 0 ]; do
    case "$1" in
        -o) shift; OUTPUT="$1";;
        --asm) SHOW_ASM=true;;
    esac
    shift
done

if [ -z "$OUTPUT" ]; then
    OUTPUT="$(basename "${SOURCE%.*}")"
fi

echo -e "${BLUE}═══ ترجمة: ${SOURCE} → ${OUTPUT} ═══${NC}"

if [ ! -x "$COMPILER" ]; then
    echo -e "${RED}خطأ: المترجم غير موجود: ${COMPILER}${NC}"
    exit 1
fi

ASM_FILE="/tmp/fdl_$(echo "$SOURCE" | sed 's/[^a-zA-Z0-9]/_/g').asm"
"$COMPILER" < "$SOURCE" > "$ASM_FILE" 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}خطأ في الترجمة!${NC}"
    cat "$ASM_FILE"
    exit 1
fi

if [ "$SHOW_ASM" = true ]; then
    cat "$ASM_FILE"
    exit 0
fi

if command -v nasm >/dev/null 2>&1; then
    OBJ_FILE="/tmp/fdl_$$.o"
    nasm -f elf64 -o "$OBJ_FILE" "$ASM_FILE"
    ld -o "$OUTPUT" "$OBJ_FILE"
    rm -f "$OBJ_FILE"
    chmod +x "$OUTPUT"
    echo -e "${GREEN}✓ تم: ${OUTPUT} ($(stat -c%s "$OUTPUT") بايت)${NC}"
else
    echo -e "${RED}تحذير: nasm غير موجود${NC}"
    echo "  sudo apt install nasm"
fi
FDL_CMD
$SUDO chmod +x "$BIN_DIR/fdl"
echo -e "    ${GREEN}✓${NC} أمر fdl (مع --ide و --update)"

# ═══════════════════════════════════════════════════
# 4. بيئة التطوير (IDE)
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[4/7]${NC} تثبيت بيئة التطوير..."

if [ -f "$DIR/فاضل_IDE.html" ]; then
    $SUDO cp "$DIR/فاضل_IDE.html" "$FDL_HOME/"
    echo -e "    ${GREEN}✓${NC} فاضل_IDE.html: $(stat -c%s "$DIR/فاضل_IDE.html") بايت"
else
    echo -e "    ${RED}✕${NC} فاضل_IDE.html غير موجود!"
fi

# ═══════════════════════════════════════════════════
# 5. الأمثلة والمنهاج
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[5/7]${NC} تثبيت الأمثلة والمنهاج..."

# أمثلة أساسية
$SUDO tee "$FDL_HOME/examples/مرحبا.فضل" > /dev/null << 'EX1'
; مرحبا بالعالم — أول برنامج بلغة فاضل
طبع:1("مرحبا بالعالم")
طبع:1("§FDL§ — لغة فاضل")
EX1

$SUDO tee "$FDL_HOME/examples/متغيرات.فضل" > /dev/null << 'EX2'
; المتغيرات والحساب
حسب:5 عرض = 10
حسب:5 طول = 20
حسب:6 مساحة = عرض * طول
طبع:1("المساحة:")
طبع:1(مساحة)
EX2

$SUDO tee "$FDL_HOME/examples/دوال.فضل" > /dev/null << 'EX3'
; الدوال — تعريف واستدعاء
حسب:7 ضعف (ن:9) {
    حسب:6 نتيجة = ن * 2
    حسب:8 نتيجة
}

حسب:7 جمع (أ:9, ب:9) {
    حسب:6 ن = أ + ب
    حسب:8 ن
}

حسب:5 س = حسب:1(ضعف, 21)
طبع:1(س)

حسب:5 ص = حسب:1(جمع, 30, 12)
طبع:1(ص)
EX3

$SUDO tee "$FDL_HOME/examples/حلقات.فضل" > /dev/null << 'EX4'
; الحلقات — العد من 1 إلى 10
حسب:5 ع = 1
حسب:5 مجموع = 0

شرط:3 (ع < 11) {
    حسب:6 مجموع = مجموع + ع
    طبع:1(ع)
    حسب:6 ع = ع + 1
}

طبع:1("المجموع:")
طبع:1(مجموع)
EX4

$SUDO tee "$FDL_HOME/examples/أصناف.فضل" > /dev/null << 'EX5'
; الأصناف — سيارة مع تسريع
صنف:7 سيارة {
    حسب:5 سرعة = 0

    حسب:7 تسريع (مقدار:9) {
        حسب:6 سرعة = سرعة + مقدار
        حسب:8 سرعة
    }
}

حسب:6 سيارة.سرعة = 100
حسب:1(سيارة.تسريع, 50)
طبع:1("السرعة:")
طبع:1(سيارة.سرعة)
EX5

# نسخ أمثلة موجودة
for f in "$DIR/examples/"*.فضل "$DIR/examples/"*.fdl 2>/dev/null; do
    [ -f "$f" ] && $SUDO cp "$f" "$FDL_HOME/examples/"
done

# المنهاج
for f in "$DIR/"*منهاج*.html "$DIR/"*منهاج*.md; do
    [ -f "$f" ] && $SUDO cp "$f" "$FDL_HOME/" && echo -e "    ${GREEN}✓${NC} $(basename "$f")"
done

EXAMPLE_COUNT=$(ls "$FDL_HOME/examples/"*.فضل "$FDL_HOME/examples/"*.fdl 2>/dev/null | wc -l)
echo -e "    ${GREEN}✓${NC} ${EXAMPLE_COUNT} مثال"

# ═══════════════════════════════════════════════════
# 6. نظام التحديث
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[6/7]${NC} إعداد نظام التحديث..."

$SUDO tee "$FDL_HOME/updates/تحديث.json" > /dev/null << EOF
{
    "version": "$VERSION",
    "date": "$(date -I)",
    "build": "$(date +%Y%m%d%H%M%S)",
    "notes": "تثبيت/تحديث لغة فاضل"
}
EOF

$SUDO tee "$FDL_HOME/updates/check_update.sh" > /dev/null << 'CHECK_SCRIPT'
#!/bin/bash
GOLD='\033[1;33m'; GREEN='\033[1;32m'; NC='\033[0m'
FDL_HOME="/usr/share/fdl"
[ -d "$HOME/.fdl" ] && [ ! -d "$FDL_HOME" ] && FDL_HOME="$HOME/.fdl"
UPDATE_DIR="$FDL_HOME/updates"

CURRENT=$(cat "$UPDATE_DIR/تحديث.json" 2>/dev/null | grep '"version"' | sed 's/.*"\([0-9.]*\)".*/\1/')
echo -e "${GOLD}§FDL§ فحص التحديثات${NC}"
echo "الإصدار الحالي: ${CURRENT:-غير معروف}"

if [ -f "$UPDATE_DIR/تحديث_جديد.json" ]; then
    NEW=$(cat "$UPDATE_DIR/تحديث_جديد.json" | grep '"version"' | sed 's/.*"\([0-9.]*\)".*/\1/')
    if [ "$NEW" != "$CURRENT" ]; then
        echo -e "${GREEN}تحديث متوفر: v${NEW}${NC}"
        echo "للتطبيق: bash $UPDATE_DIR/apply_update.sh"
    else
        echo "النظام محدّث"
    fi
else
    echo "لا توجد تحديثات"
    echo ""
    echo "للتحديث يدوياً:"
    echo "  1. ضع الملفات الجديدة في $UPDATE_DIR/"
    echo "  2. أنشئ تحديث_جديد.json بالإصدار الجديد"
    echo "  3. شغّل: bash $UPDATE_DIR/apply_update.sh"
fi
CHECK_SCRIPT
$SUDO chmod +x "$FDL_HOME/updates/check_update.sh"

$SUDO tee "$FDL_HOME/updates/apply_update.sh" > /dev/null << 'APPLY_SCRIPT'
#!/bin/bash
GOLD='\033[1;33m'; GREEN='\033[1;32m'; RED='\033[1;31m'; NC='\033[0m'
FDL_HOME="/usr/share/fdl"
[ -d "$HOME/.fdl" ] && [ ! -d "$FDL_HOME" ] && FDL_HOME="$HOME/.fdl"
UPDATE_DIR="$FDL_HOME/updates"

echo -e "${GOLD}§FDL§ تطبيق التحديث${NC}"

# نسخة احتياطية
BACKUP="$UPDATE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"
for f in "$FDL_HOME/"*.html "$FDL_HOME/المترجم"; do
    [ -f "$f" ] && cp "$f" "$BACKUP/"
done
echo "نسخة احتياطية: $BACKUP"

UPDATED=0
for f in "$UPDATE_DIR/"*.html "$UPDATE_DIR/"*.bin "$UPDATE_DIR/المترجم"; do
    if [ -f "$f" ]; then
        cp "$f" "$FDL_HOME/"
        echo -e "${GREEN}✓${NC} $(basename "$f")"
        UPDATED=1
    fi
done

if [ "$UPDATED" = "1" ]; then
    [ -f "$UPDATE_DIR/تحديث_جديد.json" ] && mv "$UPDATE_DIR/تحديث_جديد.json" "$UPDATE_DIR/تحديث.json"
    echo -e "${GREEN}تم التحديث بنجاح${NC}"
else
    echo -e "${RED}لا توجد ملفات جديدة في $UPDATE_DIR/${NC}"
fi
APPLY_SCRIPT
$SUDO chmod +x "$FDL_HOME/updates/apply_update.sh"

echo -e "    ${GREEN}✓${NC} نظام التحديث جاهز"

# ═══════════════════════════════════════════════════
# 7. اختصار سطح المكتب + ربط الامتدادات
# ═══════════════════════════════════════════════════
echo -e "${GOLD}[7/7]${NC} إنشاء الاختصارات..."

if [ "$OS" = "linux" ]; then
    # ملف .desktop
    APPS_DIR="$HOME/.local/share/applications"
    mkdir -p "$APPS_DIR"

    cat > "$APPS_DIR/fdl-ide.desktop" << EOF
[Desktop Entry]
Name=لغة فاضل §FDL§
Name[en]=Fadhil Language §FDL§
Comment=بيئة تطوير لغة فاضل v2.0 — م. فاضل عباس الجعيفري — Codec Cosmic OS
Comment[en]=Fadhil Programming Language IDE v2.0
Exec=xdg-open ${FDL_HOME}/فاضل_IDE.html
Icon=${FDL_HOME}/icons/fdl_256.png
Type=Application
Categories=Development;IDE;Education;
Keywords=fdl;fadhil;فاضل;برمجة;مترجم;عربي;programming;compiler;arabic;
Terminal=false
StartupNotify=true
MimeType=text/x-fdl;
EOF

    # نسخة على سطح المكتب
    DESKTOP="$HOME/Desktop"
    if [ -d "$DESKTOP" ]; then
        cp "$APPS_DIR/fdl-ide.desktop" "$DESKTOP/§FDL§ فاضل.desktop"
        chmod +x "$DESKTOP/§FDL§ فاضل.desktop" 2>/dev/null
        # gio لإزالة تحذير "غير موثوق"
        gio set "$DESKTOP/§FDL§ فاضل.desktop" "metadata::trusted" true 2>/dev/null
        echo -e "    ${GREEN}✓${NC} اختصار سطح المكتب"
    fi

    echo -e "    ${GREEN}✓${NC} قائمة التطبيقات"

    # ربط MIME type
    mkdir -p "$HOME/.local/share/mime/packages"
    cat > "$HOME/.local/share/mime/packages/fdl.xml" << 'MIME'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
    <mime-type type="text/x-fdl">
        <comment>FDL Source File</comment>
        <comment xml:lang="ar">ملف مصدر فاضل</comment>
        <icon name="fdl"/>
        <glob pattern="*.فضل"/>
        <glob pattern="*.fdl"/>
    </mime-type>
</mime-info>
MIME
    update-mime-database "$HOME/.local/share/mime" 2>/dev/null || true

    # ربط فتح ملفات .فضل بالـ IDE
    xdg-mime default fdl-ide.desktop text/x-fdl 2>/dev/null || true
    echo -e "    ${GREEN}✓${NC} ربط *.فضل و *.fdl"
fi

if [ "$OS" = "macos" ]; then
    echo -e "    ${GREEN}✓${NC} ماك: استخدم 'fdl --ide' من الطرفية"
fi

# === إضافة PATH ===
SHELL_RC=""
if [ -f "$HOME/.bashrc" ]; then SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.profile" ]; then SHELL_RC="$HOME/.profile"; fi

if [ -n "$SHELL_RC" ] && [ "$BIN_DIR" = "$HOME/.local/bin" ]; then
    if ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
        echo '' >> "$SHELL_RC"
        echo '# §FDL§ لغة فاضل' >> "$SHELL_RC"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    fi
fi

# ═══════════════════════════════════════════════════
# النهاية
# ═══════════════════════════════════════════════════
echo ""
echo -e "${GOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ لغة فاضل v${VERSION} — التثبيت اكتمل بنجاح${NC}"
echo -e "${GOLD}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}الأوامر:${NC}"
echo -e "    fdl                       عرض المساعدة"
echo -e "    fdl ملف.فضل              ترجمة وتشغيل"
echo -e "    fdl --ide                 بيئة التطوير"
echo -e "    fdl --update              فحص التحديثات"
echo ""
echo -e "  ${CYAN}المسارات:${NC}"
echo -e "    المترجم:   ${FDL_HOME}/المترجم"
echo -e "    الواجهة:   ${FDL_HOME}/فاضل_IDE.html"
echo -e "    الأمثلة:   ${FDL_HOME}/examples/"
echo -e "    الأيقونة:  ${FDL_HOME}/icons/fdl.svg"
echo ""
echo -e "  ${CYAN}التحديث:${NC}"
echo -e "    fdl --update              فحص"
echo -e "    ضع الملفات في ${FDL_HOME}/updates/ ثم:"
echo -e "    bash ${FDL_HOME}/updates/apply_update.sh"
echo -e "${GOLD}═══════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e "${GOLD}فتح بيئة التطوير الآن؟${NC} (ن/ل) ")" -n 1 -r
echo ""
if [[ $REPLY =~ ^[نyY]$ ]]; then
    fdl --ide 2>/dev/null || xdg-open "$FDL_HOME/فاضل_IDE.html" 2>/dev/null || echo "افتح: $FDL_HOME/فاضل_IDE.html"
fi
