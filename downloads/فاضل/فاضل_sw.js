/* عاملُ بيئةِ فاضل الخدميُّ — يجعلُها تعملُ بلا انترنت بعدَ التثبيت.
 * ⚖ نطاقُه «/downloads/فاضل/» وحدَه ⛔ لا «/downloads/» — فهناك عاملُ
 *   «فاتورة المصفوفة»، وعاملانِ على نطاقٍ واحدٍ يُلغي احدُهما الآخر.
 * ⛔ ولا يُخزَّنُ «version.json» ابدا : هو حكمُ التحديثِ فيُجلَبُ حيّا.
 */

const الخزانة = 'فاضل-8.0.0';

const الاصل = [
    './',
    './%D9%81%D8%A7%D8%B6%D9%84_IDE.html',
    './%D9%81%D8%A7%D8%B6%D9%84.webmanifest',
    './%D9%81%D8%A7%D8%B6%D9%84-192.png',
    './%D9%81%D8%A7%D8%B6%D9%84-512.png',
    './%D9%81%D8%A7%D8%B6%D9%84-maskable-512.png'
];

/* ① التثبيتُ : يُخزَّنُ الاصلُ · والبيئةُ وحدَها نحوُ 7.8 م.ب
 *    ويُجلَبُ كلٌّ على حدةٍ كي لا تُسقِطَ قطعةٌ واحدةٌ الخزنَ كلَّه */
self.addEventListener('install', ح => {
    ح.waitUntil((async () => {
        const خ = await caches.open(الخزانة);
        await Promise.all(الاصل.map(م =>
            خ.add(new Request(م, { cache: 'reload' })).catch(() => null)));
        self.skipWaiting();
    })());
});

/* ② التفعيلُ : تُمحى خزائنُ الاصداراتِ السابقةِ ⛔ ولا تُمَسُّ خزائنُ غيرِنا */
self.addEventListener('activate', ح => {
    ح.waitUntil((async () => {
        const اسماء = await caches.keys();
        await Promise.all(اسماء
            .filter(ا => ا.startsWith('فاضل-') && ا !== الخزانة)
            .map(ا => caches.delete(ا)));
        await self.clients.claim();
    })());
});

/* ③ الجلبُ : الخزانةُ اولا للاصلِ، والشبكةُ اولا لبيانِ الاصدار */
self.addEventListener('fetch', ح => {
    const ط = ح.request;
    if (ط.method !== 'GET') return;

    const ع = new URL(ط.url);
    if (ع.origin !== self.location.origin) return;

    /* بيانُ الاصدارِ حكمٌ ⟹ من الشبكةِ دائما، وان انقطعت فلا لافتة */
    if (ع.pathname.endsWith('version.json')) {
        ح.respondWith(fetch(ط, { cache: 'no-store' }).catch(() =>
            new Response('{}', { headers: { 'Content-Type': 'application/json' } })));
        return;
    }

    ح.respondWith((async () => {
        const مخزون = await caches.match(ط, { ignoreSearch: true });
        if (مخزون) {
            /* يُجدَّدُ في الخلفيةِ بلا ان ينتظرَ المستعمِل */
            ح.waitUntil((async () => {
                try {
                    const ج = await fetch(ط);
                    if (ج && ج.ok) (await caches.open(الخزانة)).put(ط, ج.clone());
                } catch (_) { /* بلا شبكةٍ ⟹ المخزونُ يكفي */ }
            })());
            return مخزون;
        }
        try {
            const ج = await fetch(ط);
            if (ج && ج.ok && ع.pathname.includes('/downloads/%D9%81%D8%A7%D8%B6%D9%84/')) {
                (await caches.open(الخزانة)).put(ط, ج.clone());
            }
            return ج;
        } catch (_) {
            const بديل = await caches.match('./%D9%81%D8%A7%D8%B6%D9%84_IDE.html');
            return بديل || new Response('لا اتصال', { status: 503 });
        }
    })());
});
