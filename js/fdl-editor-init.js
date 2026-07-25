// ═══════════════════════════════════════════════════════════════════
// fdl-editor-init.js — تهيئة المحرّر المدمج وربط الأزرار
// يعتمد على: fadhil-runtime.js + fdl-mode.js + fdl-completions.js
// ═══════════════════════════════════════════════════════════════════
(function () {
    'use strict';

    const DEFAULT_CODE = EXAMPLES.m1;

    let cm = null;
    const elEditor = document.getElementById('fdl-editor');
    const elOutput = document.getElementById('fdl-output');
    const elTemplates = document.getElementById('fdl-templates');
    const btnRun = document.getElementById('fdl-run');
    const btnCopy = document.getElementById('fdl-copy');
    const btnDownload = document.getElementById('fdl-download');
    const btnClear = document.getElementById('fdl-clear');
    const elStatus = document.getElementById('fdl-status');

    if (!elEditor) return;

    // تهيئة CodeMirror
    cm = CodeMirror.fromTextArea(elEditor, {
        mode: 'fadhil',
        theme: 'material-darker',
        lineNumbers: true,
        direction: 'rtl',
        rtlMoveVisually: false,
        lineWrapping: true,
        indentUnit: 4,
        tabSize: 4,
        autoCloseBrackets: true,
        matchBrackets: true,
        extraKeys: {
            'Ctrl-Space': function (cm) {
                cm.showHint({ hint: CodeMirror.hint.fadhil, completeSingle: false });
            },
            'Ctrl-Enter': function () { runCode(); },
            'Cmd-Enter': function () { runCode(); }
        }
    });

    cm.setValue(DEFAULT_CODE);

    // إكمال تلقائيّ عند الكتابة
    cm.on('inputRead', function (cm, change) {
        if (change.text && change.text.length === 1) {
            const ch = change.text[0];
            if (/[؀-ۿ:]/.test(ch)) {
                setTimeout(function () { window.fadhilAutoTrigger(cm); }, 50);
            }
        }
    });

    // ─── بناء قائمة القوالب من EXAMPLES ───
    const TEMPLATE_LABELS = {
        m1: { ar: 'النثر — الفكرة سطر (⟸ 5)',        icon: '﹏' },
        m2: { ar: 'الحساب الموضعيّ (⟸ 8)',           icon: '🧮' },
        m3: { ar: 'حلقة كلما:3 (⟸ 3 2 1)',           icon: '🔁' },
        m4: { ar: 'دال:14 وناد:1 (⟸ 42)',            icon: 'ƒ' },
        m5: { ar: 'شرط اذا:2 — من الاثني عشر (⟸ 7)', icon: '❓' },
        m6: { ar: 'شجرة العمر — العنوان هويّة (⟸ 36)', icon: '🌳' }
    };

    if (elTemplates) {
        elTemplates.innerHTML = '';
        Object.keys(EXAMPLES).forEach(function (key) {
            const meta = TEMPLATE_LABELS[key] || { ar: key, icon: '📄' };
            const btn = document.createElement('button');
            btn.className = 'fdl-template-btn';
            btn.innerHTML = '<span class="ico">' + meta.icon + '</span>' + meta.ar;
            btn.addEventListener('click', function () {
                cm.setValue(EXAMPLES[key]);
                cm.focus();
                setStatus('تم تحميل: ' + meta.ar);
            });
            elTemplates.appendChild(btn);
        });
    }

    // ─── الأزرار ───
    function runCode() {
        const code = cm.getValue();
        if (!code.trim()) {
            setStatus('المحرّر فارغ', 'warn');
            return;
        }
        const interp = new FDLInterpreter();
        try {
            interp.run(code);
        } catch (e) {
            elOutput.textContent = '✗ خطأ تشغيل: ' + e.message;
            elOutput.className = 'fdl-output-pane error';
            setStatus('فشل التنفيذ', 'error');
            return;
        }

        const lines = [];
        if (interp.output && interp.output.length) {
            lines.push.apply(lines, interp.output);
        }
        if (interp.errors && interp.errors.length) {
            lines.push('');
            lines.push('─── أخطاء ───');
            interp.errors.forEach(function (e) {
                lines.push('سطر ' + (e.line || '?') + ': ' + (e.msg || e));
            });
        }
        if (lines.length === 0) {
            lines.push('(لا إخراج)');
        }
        elOutput.textContent = lines.join('\n');
        elOutput.className = 'fdl-output-pane'
            + (interp.errors && interp.errors.length ? ' has-errors' : '');
        setStatus(interp.errors && interp.errors.length
            ? 'تمّ مع ' + interp.errors.length + ' خطأ'
            : '✓ نُفّذ بنجاح', interp.errors && interp.errors.length ? 'warn' : 'ok');
    }

    if (btnRun) btnRun.addEventListener('click', runCode);

    if (btnCopy) btnCopy.addEventListener('click', function () {
        navigator.clipboard.writeText(cm.getValue()).then(
            function () { setStatus('✓ نُسخ إلى الحافظة', 'ok'); },
            function () { setStatus('فشل النسخ', 'error'); }
        );
    });

    if (btnDownload) btnDownload.addEventListener('click', function () {
        const blob = new Blob([cm.getValue()], { type: 'text/plain;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'برنامج.فضل';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        setStatus('✓ تمّ تنزيل الملفّ', 'ok');
    });

    if (btnClear) btnClear.addEventListener('click', function () {
        cm.setValue('');
        elOutput.textContent = '';
        elOutput.className = 'fdl-output-pane';
        cm.focus();
        setStatus('');
    });

    function setStatus(msg, level) {
        if (!elStatus) return;
        elStatus.textContent = msg || '';
        elStatus.className = 'fdl-status' + (level ? ' ' + level : '');
    }

    setStatus('جاهز — Ctrl+Space للإكمال • Ctrl+Enter للتشغيل', 'ok');
})();
