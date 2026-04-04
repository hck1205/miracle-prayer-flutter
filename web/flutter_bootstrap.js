{{flutter_js}}
{{flutter_build_config}}

const loaderElement = document.getElementById("app-loader");

_flutter.loader.load({
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    if (loaderElement) {
      loaderElement.classList.add("is-hidden");
      window.setTimeout(() => loaderElement.remove(), 260);
    }
  },
});
