#!/usr/bin/env python3
"""بناء صفحات HTML للقصص من ملفات Markdown — يُشغّل بعد كل مزامنة"""
import os, re, glob, html, hashlib, json
from urllib.parse import quote
from datetime import datetime

SITE = "/mnt/drive_d/اكاديمية المصفوفة"
STORIES_DIR = os.path.join(SITE, "pages", "stories")

WATTPAD_PROFILE = "https://www.wattpad.com/user/zamboor15"

STORIES = [
    {
        "slug": "أخوات_موزة",
        "title_ar": "قصة أخوات موزة",
        "subtitle_ar": "رواية كاملة الفصول",
        "color": "#8b5cf6",
        "icon": "📖",
        "cover": "cover.png",
        "wattpad": "https://www.wattpad.com/story/409625308"
    },
    {
        "slug": "غضب_الله_الشديد",
        "title_ar": "قصة غضب الله الشديد",
        "subtitle_ar": "حكاية موجعة",
        "color": "#ef4444",
        "icon": "📜",
        "cover": "cover.png",
        "wattpad": "https://www.wattpad.com/story/410105347"
    },
]

# Sort chapters naturally by Arabic ordinal numbers
ARABIC_ORDINALS = {
    "الاول":1,"الأول":1,"الثاني":2,"الثالث":3,"الرابع":4,"الخامس":5,
    "السادس":6,"السابع":7,"الثامن":8,"التاسع":9,"العاشر":10,
    "الحادي_عشر":11,"الحادي عشر":11,"الثاني_عشر":12,"الثاني عشر":12,
    "الثالث_عشر":13,"الثالث عشر":13,"الرابع_عشر":14,"الرابع عشر":14,
    "الخامس_عشر":15,"السادس_عشر":16,
}

def chapter_order(filename):
    """Extract chapter number from filename for sorting."""
    name = os.path.splitext(os.path.basename(filename))[0]
    name_clean = name.replace("الفصل","").replace("اخوات موزة","").strip().replace(" ","_").replace("__","_").strip("_")
    # Try direct number first (e.g. "1,2,3")
    nums = re.findall(r'\d+', name)
    if nums:
        return int(nums[0])
    # Try Arabic ordinal
    for word, num in sorted(ARABIC_ORDINALS.items(), key=lambda x: -len(x[0])):
        if word in name_clean:
            return num
    # Try suffix أ/ب
    return 999

def md_to_html_simple(md_text):
    """Simple markdown to HTML conversion preserving Arabic."""
    lines = md_text.split("\n")
    out = []
    in_list = False
    for line in lines:
        stripped = line.strip()
        if not stripped:
            if in_list:
                out.append("</ul>")
                in_list = False
            out.append("<br>")
            continue
        # Headers
        if stripped.startswith("### "):
            if in_list: out.append("</ul>"); in_list=False
            out.append(f'<h3>{html.escape(stripped[4:])}</h3>')
        elif stripped.startswith("## "):
            if in_list: out.append("</ul>"); in_list=False
            out.append(f'<h2>{html.escape(stripped[3:])}</h2>')
        elif stripped.startswith("# "):
            if in_list: out.append("</ul>"); in_list=False
            out.append(f'<h1>{html.escape(stripped[2:])}</h1>')
        elif stripped.startswith("- ") or stripped.startswith("* "):
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f'<li>{html.escape(stripped[2:])}</li>')
        elif stripped.startswith("---") or stripped.startswith("==="):
            if in_list: out.append("</ul>"); in_list=False
            out.append("<hr>")
        else:
            if in_list: out.append("</ul>"); in_list=False
            # Bold **text**
            text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html.escape(stripped))
            text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
            out.append(f'<p>{text}</p>')
    if in_list: out.append("</ul>")
    return "\n".join(out)

CSS = """
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Segoe UI','Tahoma',sans-serif;background:#0a1628;color:#e8e8e8;line-height:2;}
.hero{text-align:center;padding:3rem 1rem 2rem;background:linear-gradient(135deg,#0a1628 0%,#1a3a5c 100%);border-bottom:3px solid #ffd700;}
.hero h1{font-size:2.4rem;color:#ffd700;margin-bottom:.5rem;}
.hero .subtitle{font-size:1.1rem;color:#b8d4e8;margin-bottom:1rem;}
.hero .meta{color:#9ab;font-size:.9rem;margin-top:.5rem;}
.controls{position:sticky;top:0;z-index:50;background:#111d30;padding:.8rem;border-bottom:1px solid #1a2a3a;display:flex;flex-wrap:wrap;justify-content:center;gap:.5rem;}
.controls a, .controls button{background:#1a2a3a;color:#b8d4e8;border:2px solid #2a5a8c;padding:.5rem 1.2rem;border-radius:8px;cursor:pointer;font-size:.9rem;text-decoration:none;transition:all .2s;}
.controls a:hover, .controls button:hover{border-color:#ffd700;color:#ffd700;}
.controls .download-btn{background:#ffd700;color:#0a1628;border-color:#ffd700;font-weight:700;}
.controls .wattpad-btn{background:#ff500a;color:#fff;border-color:#ff500a;font-weight:700;}
.controls .wattpad-btn:hover{background:#e04600;color:#fff;border-color:#e04600;}
.story-card .wattpad-link{display:inline-block;margin-top:.8rem;background:#ff500a;color:#fff;padding:.4rem 1rem;border-radius:6px;font-size:.85rem;font-weight:700;text-decoration:none;transition:all .2s;}
.story-card .wattpad-link:hover{background:#e04600;}
.container{max-width:900px;margin:0 auto;padding:2rem 1.5rem;}
.toc{background:#111d30;border-radius:12px;padding:1.5rem;margin-bottom:2rem;}
.toc h2{color:#ffd700;font-size:1.3rem;margin-bottom:1rem;border-bottom:2px solid #2a5a8c;padding-bottom:.5rem;}
.toc ul{list-style:none;padding:0;display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:.5rem;}
.toc li{padding:0;border:none;}
.toc li a{color:#b8d4e8;text-decoration:none;display:block;background:#0d1520;border:1px solid #2a5a8c;border-radius:8px;padding:.7rem 1rem;transition:all .2s;cursor:pointer;}
.toc li a:hover{color:#ffd700;border-color:#ffd700;background:#1a2a3a;}
.toc li a.active{background:#ffd700;color:#0a1628;border-color:#ffd700;font-weight:700;}
.ch-nav-top, .ch-nav-bottom{display:flex;justify-content:space-between;align-items:center;gap:.5rem;margin:1rem 0;flex-wrap:wrap;}
.ch-nav-top button, .ch-nav-bottom button{background:#1a2a3a;color:#b8d4e8;border:2px solid #2a5a8c;padding:.5rem 1.2rem;border-radius:8px;cursor:pointer;font-size:.9rem;transition:all .2s;font-family:inherit;}
.ch-nav-top button:hover:not(:disabled), .ch-nav-bottom button:hover:not(:disabled){border-color:#ffd700;color:#ffd700;}
.ch-nav-top button:disabled, .ch-nav-bottom button:disabled{opacity:.3;cursor:not-allowed;}
.ch-counter{color:#ffd700;font-weight:700;}
.ch-nav-bottom{border-top:1px solid #2a5a8c;padding-top:1rem;margin-top:2rem;}
.chapter{background:#111d30;border-radius:12px;padding:2rem;margin:2rem 0;border-right:4px solid #ffd700;}
.chapter h1, .chapter h2{color:#ffd700;margin:1rem 0 .8rem;border-bottom:1px solid #2a5a8c;padding-bottom:.5rem;}
.chapter h3{color:#4a9acf;margin:1rem 0 .5rem;}
.chapter p{margin:.8rem 0;color:#e0e0e0;text-align:justify;}
.chapter ul{margin:.8rem 0;padding-right:1.5rem;}
.chapter li{margin:.3rem 0;}
.chapter strong{color:#ffd700;}
.chapter em{color:#a5d6a7;}
.chapter hr{border:none;border-top:1px solid #2a5a8c;margin:1.5rem 0;}
.chapter img{max-width:100%;border-radius:8px;margin:1rem 0;border:1px solid #2a5a8c;}
.update-info{background:#0d1520;border:1px solid #2a5a8c;border-radius:8px;padding:1rem;margin:1rem 0;color:#9ab;font-size:.85rem;text-align:center;}
.update-info .live-dot{display:inline-block;width:8px;height:8px;background:#4a8a4f;border-radius:50%;margin-left:.5rem;animation:pulse 2s infinite;}
@keyframes pulse{0%,100%{opacity:1;}50%{opacity:.4;}}
.footer{text-align:center;padding:2rem;color:#666;font-size:.85rem;border-top:1px solid #1a2a3a;}
.footer a{color:#4a8abf;}
@media(max-width:600px){.hero h1{font-size:1.6rem;}.chapter{padding:1rem;}}
"""

INDEX_PAGE = """<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>القصص — أكاديمية المصفوفة</title>
<style>{css}
.stories-grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:1.5rem;padding:2rem 0;}}
.story-card{{background:#111d30;border-radius:12px;overflow:hidden;border-top:4px solid var(--accent,#ffd700);transition:transform .2s;text-decoration:none;color:inherit;display:block;}}
.story-card:hover{{transform:translateY(-4px);box-shadow:0 8px 24px rgba(0,0,0,.4);}}
.story-card .cover-wrap{{width:100%;aspect-ratio:3/4;overflow:hidden;background:#0a1628;display:flex;align-items:center;justify-content:center;}}
.story-card .cover-wrap img{{width:100%;height:100%;object-fit:cover;display:block;}}
.story-card .body{{padding:1.5rem;}}
.story-card h2{{color:#ffd700;font-size:1.4rem;margin-bottom:.5rem;}}
.story-card .sub{{color:#9ab;font-size:.95rem;margin-bottom:1rem;}}
.story-card .info{{color:#4a9acf;font-size:.85rem;}}
</style>
</head>
<body>
<div class="hero">
    <h1>📚 مكتبة القصص</h1>
    <div class="subtitle">قصص أكاديمية المصفوفة</div>
    <div class="meta">آخر تحديث تلقائي: <span id="lastUpdate">{last_update}</span> <span class="live-dot" style="display:inline-block;width:8px;height:8px;background:#4a8a4f;border-radius:50%;margin-right:.5rem;animation:pulse 2s infinite;"></span></div>
</div>
<div class="container">
    <div class="stories-grid">
{cards}
    </div>
</div>
<div class="footer">
    <p><a href="../../index.html">← العودة للرئيسية</a> | <a href="{wattpad_profile}" target="_blank" rel="noopener" style="color:#ff500a;">📖 حسابي على Wattpad</a></p>
    <p style="margin-top:.5rem;">© 2026 — أكاديمية المصفوفة للذكاء الاصطناعي</p>
</div>
<script>
// تحقق تلقائي من التحديثات كل دقيقتين
let lastSig = '{sig}';
async function checkUpdates() {{
    try {{
        const res = await fetch('stories/manifest.json?t=' + Date.now());
        const data = await res.json();
        if (data.signature !== lastSig) {{
            const banner = document.createElement('div');
            banner.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#ffd700;color:#0a1628;padding:1rem;text-align:center;z-index:1000;font-weight:700;cursor:pointer;';
            banner.innerHTML = '🔔 تحديث جديد متوفر — انقر للتحديث';
            banner.onclick = () => location.reload();
            document.body.prepend(banner);
        }}
    }} catch(e) {{}}
}}
setInterval(checkUpdates, 120000);
checkUpdates();
</script>
</body>
</html>
"""

def build_story(story):
    src_dir = os.path.join(STORIES_DIR, story["slug"])
    if not os.path.isdir(src_dir):
        print(f"  [SKIP] {story['slug']} — directory missing")
        return None

    md_files = sorted(glob.glob(os.path.join(src_dir, "*.md")), key=chapter_order)
    if not md_files:
        print(f"  [SKIP] {story['slug']} — no chapters")
        return None

    # Build chapters HTML — one shown at a time
    chapters_html = []
    toc_items = []
    full_text = []  # for download
    for i, md_file in enumerate(md_files, 1):
        with open(md_file, 'r', encoding='utf-8') as f:
            md_content = f.read()
        full_text.append(f"\n\n{'='*60}\n# {os.path.basename(md_file).replace('.md','')}\n{'='*60}\n\n{md_content}")
        chapter_html = md_to_html_simple(md_content)
        chapter_id = f"ch{i}"
        chapter_title = os.path.basename(md_file).replace('.md','').replace('_',' ')
        toc_items.append(f'<li><a href="#{chapter_id}" onclick="showChapter({i});return false;" data-ch="{i}">{chapter_title}</a></li>')
        # Hidden by default, only first chapter visible
        display = '' if i == 1 else 'style="display:none;"'
        chapters_html.append(f'''<div class="chapter" id="{chapter_id}" data-ch="{i}" {display}>
    <div class="ch-nav-top">
        <button onclick="showChapter({i-1 if i>1 else len(md_files)})" {'disabled' if i==1 else ''}>◀ السابق</button>
        <span class="ch-counter">الفصل {i} / {len(md_files)}</span>
        <button onclick="showChapter({i+1 if i<len(md_files) else 1})" {'disabled' if i==len(md_files) else ''}>التالي ▶</button>
    </div>
    <h2>{chapter_title}</h2>
    {chapter_html}
    <div class="ch-nav-bottom">
        <button onclick="showChapter({i-1 if i>1 else len(md_files)})" {'disabled' if i==1 else ''}>◀ الفصل السابق</button>
        <button onclick="document.getElementById('toc').scrollIntoView({{behavior:'smooth'}})">📑 الفهرس</button>
        <button onclick="showChapter({i+1 if i<len(md_files) else 1})" {'disabled' if i==len(md_files) else ''}>الفصل التالي ▶</button>
    </div>
</div>''')

    # Save full story as downloadable text
    download_file = os.path.join(src_dir, f"{story['slug']}_كاملة.txt")
    with open(download_file, 'w', encoding='utf-8') as f:
        f.write(f"{story['title_ar']}\n{'='*60}\n")
        f.write(f"التحميل: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n")
        f.write("\n".join(full_text))

    # Compute signature for change detection
    sig = hashlib.md5("|".join(open(f, 'rb').read().hex() for f in md_files).encode()).hexdigest()[:12]

    last_update = datetime.now().strftime('%Y-%m-%d %H:%M')
    cover_block = ''
    if story.get('cover') and os.path.exists(os.path.join(src_dir, story['cover'])):
        cover_block = f'<img src="{quote(story["slug"])}/{quote(story["cover"])}" alt="{html.escape(story["title_ar"])}" style="max-width:280px;width:100%;border-radius:12px;box-shadow:0 8px 24px rgba(0,0,0,.5);margin-bottom:1rem;">'
    else:
        cover_block = f'<div style="font-size:3rem;">{story["icon"]}</div>'
    page_html = f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{story['title_ar']} — أكاديمية المصفوفة</title>
<style>{CSS}</style>
</head>
<body>
<div class="hero">
    {cover_block}
    <h1>{story['title_ar']}</h1>
    <div class="subtitle">{story['subtitle_ar']} — {len(md_files)} فصلاً</div>
    <div class="meta">آخر تحديث: {last_update}</div>
</div>
<div class="controls">
    <a href="index.html">← كل القصص</a>
    <a href="../../index.html">الرئيسية</a>
    <a class="download-btn" href="{quote(story['slug'])}/{quote(story['slug']+'_كاملة.txt')}" download>⬇ تحميل القصة كاملة</a>
    {"<a class='wattpad-btn' href='" + story['wattpad'] + "' target='_blank' rel='noopener'>📖 اقرأ على Wattpad</a>" if story.get('wattpad') else ""}
    <button onclick="window.print()">🖨 طباعة</button>
</div>
<div class="container">
    <div class="update-info">
        🔄 يتم فحص التحديثات تلقائياً كل دقيقتين <span class="live-dot"></span>
    </div>
    <div class="toc" id="toc">
        <h2>📑 فهرس الفصول — انقر فصلاً للقراءة</h2>
        <ul>
{chr(10).join(toc_items)}
        </ul>
    </div>
{chr(10).join(chapters_html)}
</div>
<div class="footer">
    <p><a href="index.html">← مكتبة القصص</a> | <a href="../../index.html">الرئيسية</a></p>
    <p style="margin-top:.5rem;">© 2026 — أكاديمية المصفوفة للذكاء الاصطناعي</p>
</div>
<script>
function showChapter(n) {{
    document.querySelectorAll('.chapter').forEach(el => el.style.display = 'none');
    document.querySelectorAll('.toc li a').forEach(a => a.classList.remove('active'));
    const ch = document.querySelector('.chapter[data-ch="' + n + '"]');
    if (ch) {{
        ch.style.display = 'block';
        ch.scrollIntoView({{behavior: 'smooth', block: 'start'}});
    }}
    const link = document.querySelector('.toc li a[data-ch="' + n + '"]');
    if (link) link.classList.add('active');
    history.replaceState(null, '', '#ch' + n);
}}
// Load chapter from URL hash on page load
window.addEventListener('load', () => {{
    const m = location.hash.match(/^#ch(\\d+)$/);
    if (m) showChapter(parseInt(m[1]));
    else {{
        const first = document.querySelector('.toc li a[data-ch="1"]');
        if (first) first.classList.add('active');
    }}
}});
// Keyboard navigation
document.addEventListener('keydown', e => {{
    const visible = document.querySelector('.chapter[style*="display: block"], .chapter:not([style*="display: none"])');
    if (!visible) return;
    const cur = parseInt(visible.dataset.ch);
    const total = document.querySelectorAll('.chapter').length;
    if (e.key === 'ArrowLeft') showChapter(cur < total ? cur + 1 : 1);
    if (e.key === 'ArrowRight') showChapter(cur > 1 ? cur - 1 : total);
}});

const SIG = '{sig}';
async function check() {{
    try {{
        const r = await fetch('manifest.json?t=' + Date.now());
        const d = await r.json();
        const cur = (d.stories.find(s => s.slug === '{story["slug"]}') || {{}}).signature;
        if (cur && cur !== SIG) {{
            const b = document.createElement('div');
            b.style.cssText = 'position:fixed;top:0;left:0;right:0;background:#ffd700;color:#0a1628;padding:1rem;text-align:center;z-index:1000;font-weight:700;cursor:pointer;';
            b.innerHTML = '🔔 تحديث جديد للقصة — انقر للتحديث';
            b.onclick = () => location.reload();
            document.body.prepend(b);
        }}
    }} catch(e) {{}}
}}
setInterval(check, 120000);
check();
</script>
</body>
</html>"""

    out_file = os.path.join(STORIES_DIR, f"{story['slug']}.html")
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write(page_html)
    print(f"  [OK] {story['slug']} — {len(md_files)} chapters → {out_file}")
    cover_exists = story.get('cover') and os.path.exists(os.path.join(src_dir, story['cover']))
    return {"slug": story["slug"], "title": story["title_ar"], "chapters": len(md_files), "signature": sig, "color": story["color"], "icon": story["icon"], "subtitle": story["subtitle_ar"], "cover": story['cover'] if cover_exists else None, "wattpad": story.get("wattpad")}


def build_index(built):
    cards = []
    for s in built:
        cover_img = f'<img src="{quote(s["slug"])}/{quote(s["cover"])}" alt="{s["title"]}" loading="lazy">' if s.get('cover') else f'<span style="font-size:4rem">{s["icon"]}</span>'
        wattpad_btn = f'<a class="wattpad-link" href="{s["wattpad"]}" target="_blank" rel="noopener" onclick="event.stopPropagation();">📖 Wattpad</a>' if s.get("wattpad") else ""
        cards.append(f"""        <div class="story-card-wrap">
        <a href="{quote(s['slug'])}.html" class="story-card" style="--accent:{s['color']};border-top-color:{s['color']};">
            <div class="cover-wrap">{cover_img}</div>
            <div class="body">
                <h2>{s['title']}</h2>
                <div class="sub">{s['subtitle']}</div>
                <div class="info">📖 {s['chapters']} فصلاً — انقر للقراءة</div>
                {wattpad_btn}
            </div>
        </a>
        </div>""")

    sig = hashlib.md5("|".join(s["signature"] for s in built).encode()).hexdigest()[:12]
    last_update = datetime.now().strftime('%Y-%m-%d %H:%M')

    page = INDEX_PAGE.format(css=CSS, cards="\n".join(cards), last_update=last_update, sig=sig, wattpad_profile=WATTPAD_PROFILE)
    out = os.path.join(STORIES_DIR, "index.html")
    with open(out, 'w', encoding='utf-8') as f:
        f.write(page)

    manifest = {"signature": sig, "last_update": last_update, "stories": built}
    with open(os.path.join(STORIES_DIR, "manifest.json"), 'w', encoding='utf-8') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"  [OK] Index built with {len(built)} stories")


def main():
    print(f"=== Building stories @ {datetime.now()} ===")
    built = []
    for s in STORIES:
        result = build_story(s)
        if result:
            built.append(result)
    if built:
        build_index(built)
    print(f"=== Done — {len(built)} stories built ===")

if __name__ == "__main__":
    main()
