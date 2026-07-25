/**
 * Floating Edit Button
 * يظهر زر تعديل عائم في كل صفحة إذا كان المستخدم مسجّل دخوله في لوحة التحرير
 * Shows a floating edit button on every page if the user is logged into admin-editor
 */
(function() {
    'use strict';

    // لا تُظهر الزر إلا إذا كان المستخدم قد سجّل دخوله في لوحة التحرير
    if (!localStorage.getItem('gh_pat')) return;

    // لا تُظهر الزر على صفحة الإدارة نفسها
    var p = location.pathname;
    if (p.indexOf('admin-editor.html') !== -1 || p.indexOf('admin.html') !== -1) return;

    // استخرج المسار النسبي داخل المستودع
    var repoPath = p.replace('/almasfoufaakademy/', '').replace(/^\//, '');
    if (!repoPath || repoPath === '') repoPath = 'index.html';
    // إذا انتهى بـ / افترض index.html
    if (repoPath.endsWith('/')) repoPath += 'index.html';

    // ابنِ رابط صفحة التحرير
    var editorUrl;
    if (p.indexOf('/almasfoufaakademy/') !== -1) {
        editorUrl = '/almasfoufaakademy/pages/admin-editor.html?edit=' + encodeURIComponent(repoPath);
    } else {
        // للتشغيل المحلي
        var depth = (p.match(/\//g) || []).length - 1;
        var up = depth > 1 ? '../'.repeat(depth - 1) : '';
        editorUrl = up + 'pages/admin-editor.html?edit=' + encodeURIComponent(repoPath);
    }

    function createButton() {
        var btn = document.createElement('a');
        btn.href = editorUrl;
        btn.title = 'تعديل هذه الصفحة في لوحة التحرير';
        btn.setAttribute('aria-label', 'تعديل هذه الصفحة');
        btn.innerHTML = '<span style="font-size:18px;">✏</span> <span>تعديل</span>';
        btn.style.cssText = [
            'position:fixed',
            'bottom:20px',
            'left:20px',
            'background:linear-gradient(135deg,#6366f1,#8b5cf6)',
            'color:white',
            'padding:10px 18px',
            'border-radius:50px',
            'text-decoration:none',
            'box-shadow:0 4px 15px rgba(99,102,241,0.4)',
            'z-index:9999',
            'font-size:14px',
            'font-family:inherit',
            'display:flex',
            'align-items:center',
            'gap:6px',
            'transition:all 0.2s ease',
            'cursor:pointer',
            'direction:rtl',
            'border:none'
        ].join(';');

        btn.addEventListener('mouseenter', function() {
            btn.style.transform = 'translateY(-2px)';
            btn.style.boxShadow = '0 8px 25px rgba(99,102,241,0.5)';
        });
        btn.addEventListener('mouseleave', function() {
            btn.style.transform = 'translateY(0)';
            btn.style.boxShadow = '0 4px 15px rgba(99,102,241,0.4)';
        });

        document.body.appendChild(btn);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', createButton);
    } else {
        createButton();
    }
})();
