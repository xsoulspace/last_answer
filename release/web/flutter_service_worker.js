'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "226f093cc131f04de4a19cb62c21daeb",
"version.json": "a9526393de7d3dfdc0e0c9dec9543b58",
"index.html": "a27036a378ce0d7b19edfb79f547634a",
"/": "a27036a378ce0d7b19edfb79f547634a",
"main.dart.js": "3be8b8583eca10b0bc1a1996d9cc15b9",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "16e424e171d2abe7aaa2a68f2c66740c",
"icons/icon-16.png": "16e424e171d2abe7aaa2a68f2c66740c",
"icons/icon-192.png": "934f771e6d8f388259f602dcbeb5aa23",
"icons/icon-48.png": "13244eda7664626702bb1f65a316acc2",
"icons/Icon-maskable-192.png": "934f771e6d8f388259f602dcbeb5aa23",
"icons/Icon-maskable-512.png": "aeff152814c020c3850eefa1ecc07d6f",
"icons/icon-128.png": "284cc488405f72b961646d401cc316b7",
"icons/icon-32.png": "3542b91e98205f7c567d0d6b147965f0",
"icons/icon-24.png": "80470217d51eb26600393fe2b5978a00",
"icons/icon-512.png": "aeff152814c020c3850eefa1ecc07d6f",
"manifest.json": "601f27b8415bdad8e296ec7d98227fc1",
"assets/AssetManifest.json": "5af648214f84c7cb88a9ec805dc84c0c",
"assets/NOTICES": "866391bd3fdca2091373782faa588a04",
"assets/FontManifest.json": "fb6b8dd3180ac4db433e63287147047e",
"assets/AssetManifest.bin.json": "0394d6bb2eb55b17f5875da91a367e85",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "132cb8f1fb0029f69cc83a5afa293d31",
"assets/packages/wiredash/lib/assets/fonts/Wirecons.ttf": "39dff657dd43bfb7ab7e25406d4baab7",
"assets/packages/wiredash/lib/assets/fonts/Inter-Bold.ttf": "cef517a165e8157d9f14a0911190948d",
"assets/packages/wiredash/lib/assets/fonts/Inter-Regular.ttf": "eba360005eef21ac6807e45dc8422042",
"assets/packages/wiredash/lib/assets/fonts/Inter-SemiBold.ttf": "3e87064b7567bef4ecd2ba977ce028bc",
"assets/packages/wiredash/assets/images/logo_white.png": "d51118529c8b6f919c485cd81e9a840e",
"assets/packages/core/assets/json/special_emoji.json": "a47c59e387c2b94c9aec41940ee7690a",
"assets/packages/core/assets/json/updates_notifications.json": "48b3dfa320313fd677ff79257493c3af",
"assets/packages/core/assets/json/emojis.json": "a987d3ce87eab5842b16a709c55b8452",
"assets/packages/core/assets/icons/vk_logo_white.svg": "0bfffef24e3efdcdaa72ed74291446e4",
"assets/packages/core/assets/icons/instagram_logo_black.png": "0e84d5926187e7a3b785febd3a55bf1d",
"assets/packages/core/assets/icons/instagram_logo_colorful.png": "afac8448aec704bc200f2201682cab1d",
"assets/packages/core/assets/icons/fb_logo_black.png": "6c4026e15399f60aac211c1a25fdd639",
"assets/packages/core/assets/icons/vk_logo_blue.svg": "6caeb44b369b1f795ae7f54e0c93a5e4",
"assets/packages/core/assets/icons/discord_logo_white.svg": "145dc557845548a36a82337912ca3ac5",
"assets/packages/core/assets/icons/discord_logo_blue.svg": "3437c10597c1526c3dbd98c737c2bcae",
"assets/packages/core/assets/icons/x_logo_white.png": "1092570c039452d90551d328e0652bc9",
"assets/packages/core/assets/icons/logo_512.png": "aeff152814c020c3850eefa1ecc07d6f",
"assets/packages/core/assets/icons/logo_24.png": "80470217d51eb26600393fe2b5978a00",
"assets/packages/core/assets/icons/logo_300.png": "f33d1924cd5211e245b8704e372e6be9",
"assets/packages/core/assets/icons/logo_128.png": "284cc488405f72b961646d401cc316b7",
"assets/packages/core/assets/icons/logo_32.png": "3542b91e98205f7c567d0d6b147965f0",
"assets/packages/core/assets/icons/logo_16.png": "16e424e171d2abe7aaa2a68f2c66740c",
"assets/packages/core/assets/icons/vk_logo_black.svg": "fbf3b077472ced584c891620bec6fd65",
"assets/packages/core/assets/icons/logo.png": "479d556fb2eb36f25a63441f0e18ab75",
"assets/packages/core/assets/icons/fb_logo_white.png": "d651082e2134a2aad22e1db5b734942b",
"assets/packages/core/assets/icons/fb_logo_blue.png": "5d6ea38a769498dfc19fe6389d14db39",
"assets/packages/core/assets/icons/logo_1024.png": "e9e64361f5c8f766c9fbfa90fdc02491",
"assets/packages/core/assets/icons/idea.svg": "8411d4099a55bbf70ee17a9abfbe760b",
"assets/packages/core/assets/icons/logo_256.png": "c20d6aa6835172132af5ab3f48c977bb",
"assets/packages/core/assets/icons/discord_logo_black.svg": "2d20a45d79110dc5bf947137e9d99b66",
"assets/packages/core/assets/icons/x_logo_black.png": "c019bd434e5489eb40e386b60cf045c9",
"assets/packages/core/assets/icons/logo_1080.png": "8f5b2b37f8e8bebefc80746558e309d9",
"assets/packages/core/assets/icons/logo_48.png": "13244eda7664626702bb1f65a316acc2",
"assets/packages/core/assets/icons/logo_192.png": "934f771e6d8f388259f602dcbeb5aa23",
"assets/packages/core/assets/icons/logo_64.png": "7ead2e6d1c0e59d9dca59679b9acb8f4",
"assets/packages/core/google_fonts/NotoSans-Regular.ttf": "d5649a4a1b2eeb6b7add5a310414c48e",
"assets/packages/core/google_fonts/IBMPlexSans-SemiBoldItalic.ttf": "25178032f9e824996f04622926833459",
"assets/packages/core/google_fonts/IBMPlexSans-Medium.ttf": "ee83103a4a777209b0f759a4ff598066",
"assets/packages/core/google_fonts/NotoSans-Bold.ttf": "91fd88919f019f29caee6cfe0f5d88bc",
"assets/packages/core/google_fonts/NotoColorEmoji.ttf": "b0b162dbe8fe80adae4f553c67f812dc",
"assets/packages/core/google_fonts/IBMPlexSans-SemiBold.ttf": "1ca9107e7544d3424419585c7c84cb67",
"assets/packages/core/google_fonts/IBMPlexSans-MediumItalic.ttf": "eb7dadea8e7c37ce1a1406045dda7c1e",
"assets/packages/core/google_fonts/OFL.txt": "2c309aad324a15dea6c68973d9bb7cf0",
"assets/packages/core/google_fonts/IBMPlexSans-LightItalic.ttf": "453b2bbf7ad0bb52a93f64ac96641f24",
"assets/packages/core/google_fonts/NotoSans-BoldItalic.ttf": "cc259a7e9911128c4ecd322e7584aa90",
"assets/packages/core/google_fonts/IBMPlexSans-ExtraLight.ttf": "dc4c7cbc44c833f9a7540a6464a015fa",
"assets/packages/core/google_fonts/IBMPlexSans-Thin.ttf": "969246a285e76a59329d5e003f1a28a0",
"assets/packages/core/google_fonts/IBMPlexSans-ThinItalic.ttf": "984c6ee79e119ff312f599e0e1b21932",
"assets/packages/core/google_fonts/IBMPlexSans-BoldItalic.ttf": "ee425cc83f37323665790c89758cf359",
"assets/packages/core/google_fonts/IBMPlexSans-Light.ttf": "29047654270fd882ab9e9ec10e28f7c5",
"assets/packages/core/google_fonts/IBMPlexSans-Italic.ttf": "40bbef08ca6f6edea2a9a9e882541ce0",
"assets/packages/core/google_fonts/IBMPlexSans-Regular.ttf": "c02b4dc6554c116e4c40f254889d5871",
"assets/packages/core/google_fonts/IBMPlexSans-ExtraLightItalic.ttf": "71efb00c2fc462eb4c4f778dac53e6dc",
"assets/packages/core/google_fonts/IBMPlexSans-Bold.ttf": "5159a5d89abe8bf68b09b569dbeccbc0",
"assets/packages/core/google_fonts/NotoSans-Italic.ttf": "27f0f38979ffb1932d719b6aee9918fb",
"assets/packages/serverpod_auth_google_flutter/assets/google-icon.png": "ed3d85e924ac22e46489e367ee067f59",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "6012afdbab87fbc29e30dc1e1de082a8",
"assets/fonts/MaterialIcons-Regular.otf": "f04c15938ced2a6d70c9b23bd6db753f",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
