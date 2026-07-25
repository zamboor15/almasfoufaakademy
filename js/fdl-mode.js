// ═══════════════════════════════════════════════════════════════════
// fdl-mode.js — وضع CodeMirror لتلوين لغة فاضل
// يعتمد على الثوابت في fadhil-runtime.js (FDL.KEYWORDS / CONDITIONS)
// ═══════════════════════════════════════════════════════════════════
(function (CodeMirror) {
    'use strict';

    function isArabic(ch) {
        if (!ch) return false;
        const c = ch.charCodeAt(0);
        return (c >= 0x0600 && c <= 0x06FF) || (c >= 0x0750 && c <= 0x077F)
            || ch === '_' || ch === 'ـ';
    }
    function isDigit(ch) { return ch >= '0' && ch <= '9'; }

    CodeMirror.defineMode('fadhil', function () {
        return {
            startState: function () {
                return { afterKeyword: false };
            },

            token: function (stream, state) {
                if (stream.eatSpace()) return null;

                if (stream.match(/^--.*$/)) return 'comment';
                if (stream.match(/^;.*$/)) return 'comment';

                if (stream.match(/^"[^"]*"/)) return 'string';

                if (stream.match(/^[0-9]+(\.[0-9]+)+/)) return 'number';
                if (stream.match(/^-?[0-9]+(\.[0-9]+)?/)) return 'number';

                if (stream.match(/^:[0-9]+/)) return 'attribute';

                if (stream.match(/^(==|!=|>=|<=|[+\-*\/%><=])/)) return 'operator';

                if (stream.match(/^[(){}\[\],]/)) return 'bracket';
                if (stream.match(/^\./)) return 'punctuation';

                const ch = stream.peek();
                if (isArabic(ch)) {
                    let word = '';
                    while (!stream.eol()) {
                        const c = stream.peek();
                        if (isArabic(c) || isDigit(c)) { word += c; stream.next(); }
                        else break;
                    }
                    if (FDL.KEYWORDS.includes(word)) return 'keyword';
                    if (FDL.CONDITIONS.includes(word)) return 'def';
                    return 'variable';
                }

                stream.next();
                return null;
            }
        };
    });

    CodeMirror.defineMIME('text/x-fadhil', 'fadhil');
})(window.CodeMirror);
