{{flutter_js}}
{{flutter_build_config}}

const loaderElement = document.getElementById("app-loader");

async function waitForStableFirstPaint() {
  if ("fonts" in document) {
    try {
      await Promise.race([
        document.fonts.ready,
        new Promise((resolve) => window.setTimeout(resolve, 1200)),
      ]);
    } catch (_) {
      // Ignore font readiness issues and continue booting.
    }
  }

  await new Promise((resolve) => window.requestAnimationFrame(() => resolve()));
}

_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    await waitForStableFirstPaint();

    if (loaderElement) {
      loaderElement.classList.add("is-hidden");
      window.setTimeout(() => loaderElement.remove(), 260);
    }
  },
});
