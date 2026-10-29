// Repositório da Lulu — deixa o app instalável e abrindo mesmo sem internet.
// Os dados (Supabase) não passam por aqui; só os arquivos do próprio site.
const CACHE = "lulu-v7";
const ARQUIVOS = ["./", "index.html", "config.js", "manifest.json", "icon.svg", "icon-192.png", "icon-512.png", "icon-180.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ARQUIVOS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

// Primeiro tenta a internet (para pegar a versão nova); sem conexão, usa a cópia guardada.
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET" || new URL(req.url).origin !== location.origin) return;
  e.respondWith(
    fetch(req).then(res => {
      const copia = res.clone();
      caches.open(CACHE).then(c => c.put(req.mode === "navigate" ? "./" : req, copia));
      return res;
    }).catch(() => caches.match(req.mode === "navigate" ? "./" : req, {ignoreSearch: true}))
  );
});
