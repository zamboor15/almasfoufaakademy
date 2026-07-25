// ═══════════════════════════════════════════════════════════════════
// fdl-completions.js — قاموس الإكمال التلقائيّ للغة فاضل
// يبني الفهرس من ثوابت fadhil-runtime.js (لا تكرار)
// ═══════════════════════════════════════════════════════════════════
(function (CodeMirror) {
    'use strict';

    // وصف لكلّ كلمة مفتاحيّة
    const KEYWORD_DESC = {
        'حسب': 'تعريف/تعيين متغيّر أو دالة — يأخذ وزناً (:5 إنشاء، :6 تعديل، :7 تعريف دالة، :12 ثابت...)',
        'طبع': 'طباعة قيمة على الإخراج — يُستخدم عادةً مع :1 (استدعاء)',
        'شرط': 'شرط أو حلقة — :3 = while، يقبل تعبيراً منطقيّاً بين قوسين',
        'صنف': 'تعريف صنف (class) — يأخذ :7 ويحوي حقولاً ودوالاً',
    };

    // وصف لكلّ أداة شرط
    const CONDITION_DESC = {
        'إنْ': 'شرط عامّ — يُختبر التعبير، تُنفَّذ الكتلة إن كان صحيحاً',
        'إن': 'مرادف لـ إنْ — شرط عامّ',
        'ان': 'مرادف لـ إنْ بدون همزة — شرط عامّ',
        'اذا': 'شرط مباشر/واقعيّ — للحالات الفعليّة',
        'لو': 'شرط افتراضيّ — للحالات الفرضيّة',
        'كلما': 'تكرار — حلقة تعمل ما دام الشرط صحيحاً',
        'متى': 'شرط زمنيّ — للحالات المرتبطة بوقت/زمن',
        'من': 'شرط على الفاعل — اختبار هويّة المنفِّذ',
        'مَنْ': 'شرط على الفاعل (مع همزة) — اختبار هويّة المنفِّذ',
        'ما': 'شرط على المفعول/المحتوى',
        'اينما': 'شرط مكانيّ — اختبار موقع/منطقة',
    };

    // قوالب جاهزة (snippets)
    const SNIPPETS = [
        { label: 'مرحبا', detail: 'برنامج Hello World', text: 'طبع:1("مرحباً بالعالم")' },
        { label: 'متغيّر', detail: 'إنشاء متغيّر :5', text: 'حسب:5 س = 10' },
        { label: 'ثابت', detail: 'إنشاء ثابت :12', text: 'حسب:12 ط = 314' },
        { label: 'دالة', detail: 'تعريف دالة كاملة', text: 'حسب:7 الاسم(ن)\n0 حسب:9 ن\n1 حسب:5 نت = ن * 2\n2 حسب:8 نت' },
        { label: 'حلقة', detail: 'حلقة شرط:3 (while)', text: 'حسب:5 ع = 1\nشرط:3 (ع < 10)\n0 طبع:1(ع)\n1 حسب:6 ع = ع + 1' },
        { label: 'شرط_إن', detail: 'شرط إنْ', text: 'إنْ (س > 0)\n0 طبع:1("موجب")' },
        { label: 'قائمة', detail: 'قائمة :15', text: 'حسب:15 قائمة(5)' },
        { label: 'صنف', detail: 'تعريف صنف :7', text: 'صنف:7 الاسم\n0 حسب:5 حقل = 0' },
    ];

    // بناء الفهرس مرّةً واحدة
    let CACHE = null;
    function buildIndex() {
        if (CACHE) return CACHE;
        const list = [];

        // 1) الكلمات المفتاحيّة (4)
        FDL.KEYWORDS.forEach(k => {
            list.push({
                text: k,
                displayText: k,
                category: 'keyword',
                detail: 'كلمة مفتاحيّة',
                doc: KEYWORD_DESC[k] || ''
            });
        });

        // 2) أدوات الشرط (11)
        FDL.CONDITIONS.forEach(c => {
            list.push({
                text: c,
                displayText: c,
                category: 'condition',
                detail: 'أداة شرط',
                doc: CONDITION_DESC[c] || ''
            });
        });

        // 3) الأوزان (13) — تُكتب كـ :N
        Object.entries(FDL.WEIGHTS).forEach(([num, w]) => {
            list.push({
                text: ':' + num,
                displayText: ':' + num + ' — ' + w.name,
                category: 'weight',
                detail: w.label,
                doc: 'الوزن ' + num + ' (' + w.name + ') — ' + w.label
            });
        });

        // 4) الجذور الرقميّة (8)
        Object.entries(FDL.NUMERIC_ROOTS).forEach(([root, name]) => {
            list.push({
                text: root,
                displayText: root + ' (' + name + ')',
                category: 'root',
                detail: 'جذر رقميّ',
                doc: 'الجذر ' + root + ' = ' + name
            });
        });

        // 5) العمليّات (11)
        FDL.OPERATORS.forEach(op => {
            list.push({
                text: op,
                displayText: op,
                category: 'operator',
                detail: 'عامل',
                doc: 'عامل: ' + op
            });
        });

        // 6) القوالب (snippets)
        SNIPPETS.forEach(s => {
            list.push({
                text: s.text,
                displayText: '⚡ ' + s.label,
                category: 'snippet',
                detail: s.detail,
                doc: s.detail + '\n\n' + s.text
            });
        });

        CACHE = list;
        return list;
    }

    // ─── دالّة الـ hint ───
    function fadhilHint(cm, options) {
        const cur = cm.getCursor();
        const line = cm.getLine(cur.line);
        const before = line.slice(0, cur.ch);

        // التقاط الكلمة الحاليّة (عربيّة، رمز :، عوامل)
        const tokenMatch = before.match(/(:[0-9]*|[؀-ۿݐ-ݿ_ـ0-9]+|[+\-*\/%><=!]+|\.?[0-9]+(\.[0-9]+)*)$/);
        const token = tokenMatch ? tokenMatch[0] : '';
        const start = tokenMatch ? cur.ch - token.length : cur.ch;

        const items = buildIndex();
        let filtered;

        if (token === '') {
            // لا شيء قبل المؤشّر — اعرض الكلمات المفتاحيّة + الشروط
            filtered = items.filter(it =>
                it.category === 'keyword' || it.category === 'condition' || it.category === 'snippet'
            );
        } else if (token.startsWith(':')) {
            // كتب : — اعرض الأوزان فقط
            filtered = items.filter(it => it.category === 'weight'
                && it.text.startsWith(token));
        } else {
            // مطابقة prefix على الـ text أو الـ displayText
            filtered = items.filter(it =>
                it.text.startsWith(token) ||
                (it.category === 'snippet' && it.displayText.includes(token))
            );
        }

        // إن لم يوجد تطابق، أعد كلّ شيء (fallback)
        if (filtered.length === 0 && token !== '') {
            filtered = items.filter(it => it.text.includes(token));
        }

        return {
            list: filtered.map(it => ({
                text: it.text,
                displayText: it.displayText,
                className: 'fdl-hint-' + it.category,
                hint: function (cm, data, completion) {
                    cm.replaceRange(completion.text,
                        { line: cur.line, ch: start },
                        { line: cur.line, ch: cur.ch });
                },
                render: function (el, data, completion) {
                    const main = document.createElement('div');
                    main.className = 'fdl-hint-main';
                    main.textContent = completion.displayText;
                    el.appendChild(main);
                    if (it.detail) {
                        const det = document.createElement('div');
                        det.className = 'fdl-hint-detail';
                        det.textContent = it.detail;
                        el.appendChild(det);
                    }
                }
            })),
            from: { line: cur.line, ch: start },
            to: { line: cur.line, ch: cur.ch }
        };
    }

    CodeMirror.registerHelper('hint', 'fadhil', fadhilHint);

    // مفتاح الإكمال التلقائيّ على ضربات معيّنة
    window.fadhilAutoTrigger = function (cm) {
        const cur = cm.getCursor();
        const line = cm.getLine(cur.line);
        const before = line.slice(0, cur.ch);
        // حفّز عند : أو بعد حرف عربيّ
        if (/[؀-ۿݐ-ݿ:]/.test(before.slice(-1))) {
            cm.showHint({ hint: fadhilHint, completeSingle: false });
        }
    };
})(window.CodeMirror);
