const CACHE_NAME = 'kondate-planner-v2';
const ASSETS = [
  './',
  './index.html',
  './data.json',
  './recipes.json',
  './manifest.json',
  './icon-192.svg',
  './icon-512.svg'
];

// インストール時にファイルをキャッシュ
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

// 古いキャッシュを削除
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      ))
      .then(() => self.clients.claim())
  );
});

// ネットワーク優先、失敗したらキャッシュから返す
// 同一オリジンのみキャッシュ（外部リソースはキャッシュしない）
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  event.respondWith(
    fetch(event.request)
      .then(response => {
        if (response.ok && url.origin === self.location.origin) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        }
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
