if(!self.define){let e,i={};const n=(n,s)=>(n=new URL(n+".js",s).href,i[n]||new Promise((i=>{if("document"in self){const e=document.createElement("script");e.src=n,e.onload=i,document.head.appendChild(e)}else e=n,importScripts(n),i()})).then((()=>{let e=i[n];if(!e)throw new Error(`Module ${n} didn’t register its module`);return e})));self.define=(s,r)=>{const f=e||("document"in self?document.currentScript.src:"")||location.href;if(i[f])return;let o={};const c=e=>n(e,f),d={module:{uri:f},exports:o,require:c};i[f]=Promise.all(s.map((e=>d[e]||c(e)))).then((e=>(r(...e),o)))}}define(["./workbox-3e911b1d"],(function(e){"use strict";self.skipWaiting(),e.clientsClaim(),e.precacheAndRoute([{url:"assets/index-C5Mjkk7d.js",revision:null},{url:"assets/index-DKjsOZTf.css",revision:null},{url:"index.html",revision:"a5c771dc77123552767a91ef5c8a729e"},{url:"registerSW.js",revision:"1872c500de691dce40960bb85481de07"},{url:"favicon.ico",revision:"3ca4bf461720ad08a4948d39ea40b03f"},{url:"pwa-512x512.png",revision:"2bc5db531ece8d0fc82c22e423f72f0b"},{url:"pwa-64x64.png",revision:"149db725e5f67b0c735d7923825f69f2"},{url:"pwa-192x192.png",revision:"90c0579f60e6f192adf0963df7f87223"},{url:"maskable-icon-512x512.png",revision:"79ec067493f7fefecd3c74cdf6e22f4a"},{url:"manifest.webmanifest",revision:"13a97f38aa9cf5d26263079d6301026b"}],{}),e.cleanupOutdatedCaches(),e.registerRoute(new e.NavigationRoute(e.createHandlerBoundToURL("index.html")))}));
