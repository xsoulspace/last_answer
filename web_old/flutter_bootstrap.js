{
  {
    flutter_js;
  }
}
{
  {
    flutter_build_config;
  }
}

window.addEventListener("load", function (ev) {
  // Mobile detection utility
  function isMobile() {
    if ("maxTouchPoints" in navigator) return navigator.maxTouchPoints > 0;

    const mQ = matchMedia?.("(pointer:coarse)");
    if (mQ?.media === "(pointer:coarse)") return !!mQ.matches;

    if ("orientation" in window) return true;

    return /\b(Android|Windows Phone|iPhone|iPad|iPod|Android|webOS|BlackBerry|IEMobile|Opera Mini)\b/i.test(
      navigator.userAgent
    );
  }

  // Service Worker initialization
  if (navigator.serviceWorker) {
    console.log("SW found");
    navigator.serviceWorker.ready.then((registration) => {
      console.log("requesting offline resources");
      registration.active.postMessage("downloadOffline");
    });
  }

  var loading = document.querySelector("#loading");
  var loadingContainer = document.querySelector("#loading_container");
  var hostElement = document.querySelector("#flutter_app");

  // Modern Flutter web initialization
  _flutter.loader.load({
    serviceWorker: {
      serviceWorkerVersion: "{{flutter_service_worker_version}}",
    },
    onEntrypointLoaded: async function (engineInitializer) {
      loading.classList.add("main_done");

      // Mobile compatibility - conditionally use hostElement
      let appRunner = isMobile()
        ? await engineInitializer.initializeEngine()
        : await engineInitializer.initializeEngine({
            hostElement: hostElement,
          });

      console.log("appRunner");
      loading.classList.add("init_done");
      await appRunner.runApp();
      console.log("runApp - done");

      window.setTimeout(function () {
        console.log("removing");
        loadingContainer.remove();
      }, 200);
    },
  });
});
