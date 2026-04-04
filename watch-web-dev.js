const http = require("http");
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const projectRoot = __dirname;
const buildRoot = path.resolve(projectRoot, "build/web");
const host = process.env.MIRACLE_PRAYER_WEB_HOST || "localhost";
const port = Number(process.env.MIRACLE_PRAYER_WEB_PORT || "5173");
const watchTargets = [
  "lib",
  "web",
  "pubspec.yaml",
  "pubspec.lock",
  "assets",
].map((target) => path.resolve(projectRoot, target));

const mime = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".wasm": "application/wasm",
  ".ico": "image/x-icon",
  ".txt": "text/plain; charset=utf-8",
};

const clients = new Set();
const watchers = [];
let buildInProgress = false;
let buildQueued = false;
let buildScheduled = null;

startServer();
setupWatchers();
runBuild("initial startup");

function startServer() {
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent((req.url || "/").split("?")[0]);

    if (urlPath === "/__miracle_reload") {
      handleReloadStream(req, res);
      return;
    }

    const filePath = resolveFilePath(urlPath);

    fs.readFile(filePath, (error, data) => {
      if (error) {
        res.writeHead(500);
        res.end(String(error));
        return;
      }

      const extension = path.extname(filePath).toLowerCase();
      const contentType = mime[extension] || "application/octet-stream";

      res.writeHead(200, {
        "Content-Type": contentType,
        "Cache-Control": "no-store",
      });

      if (extension === ".html") {
        res.end(injectReloadClient(data.toString("utf8")));
        return;
      }

      res.end(data);
    });
  });

  server.listen(port, host, () => {
    console.log(`[watch] Miracle Prayer is available at http://${host}:${port}`);
    console.log("[watch] Waiting for file changes...");
  });

  server.on("error", (error) => {
    console.error(error);
    process.exit(1);
  });
}

function handleReloadStream(req, res) {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-store",
    Connection: "keep-alive",
  });
  res.write("\n");
  clients.add(res);

  req.on("close", () => {
    clients.delete(res);
  });
}

function resolveFilePath(urlPath) {
  let filePath = path.join(
    buildRoot,
    urlPath === "/" ? "index.html" : urlPath.replace(/^\//, ""),
  );

  if (!filePath.startsWith(buildRoot)) {
    return path.join(buildRoot, "index.html");
  }

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, "index.html");
  }

  if (!fs.existsSync(filePath)) {
    filePath = path.join(buildRoot, "index.html");
  }

  return filePath;
}

function injectReloadClient(html) {
  const script = `
<script>
(() => {
  const source = new EventSource("/__miracle_reload");
  source.addEventListener("reload", () => window.location.reload());
})();
</script>`;

  if (html.includes("/__miracle_reload")) {
    return html;
  }

  if (html.includes("</body>")) {
    return html.replace("</body>", `${script}\n</body>`);
  }

  return `${html}\n${script}`;
}

function setupWatchers() {
  for (const target of watchTargets) {
    if (!fs.existsSync(target)) {
      continue;
    }

    const watcher = fs.watch(
      target,
      { recursive: fs.statSync(target).isDirectory() },
      (_, filename) => {
        if (!filename || shouldIgnoreChange(filename)) {
          return;
        }

        scheduleBuild(String(filename));
      },
    );

    watcher.on("error", (error) => {
      console.error(`[watch] Watcher error for ${target}:`, error);
    });

    watchers.push(watcher);
  }
}

function shouldIgnoreChange(filename) {
  return (
    filename.includes(".dart_tool") ||
    filename.includes("build\\") ||
    filename.includes("build/")
  );
}

function scheduleBuild(reason) {
  if (buildScheduled !== null) {
    clearTimeout(buildScheduled);
  }

  buildScheduled = setTimeout(() => {
    buildScheduled = null;
    runBuild(`change detected in ${reason}`);
  }, 250);
}

function runBuild(reason) {
  if (buildInProgress) {
    buildQueued = true;
    return;
  }

  buildInProgress = true;
  console.log(`[watch] Rebuilding (${reason})...`);

  const child = spawn("cmd.exe", ["/c", "build-web-dev.bat"], {
    cwd: projectRoot,
    env: process.env,
    stdio: "inherit",
  });

  child.on("exit", (code) => {
    buildInProgress = false;

    if (code === 0) {
      notifyClients();
      console.log("[watch] Build complete. Browser reload triggered.");
    } else {
      console.error(`[watch] Build failed with exit code ${code}.`);
    }

    if (buildQueued) {
      buildQueued = false;
      runBuild("queued changes");
    }
  });
}

function notifyClients() {
  for (const client of clients) {
    client.write("event: reload\n");
    client.write(`data: ${Date.now()}\n\n`);
  }
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

function shutdown() {
  for (const watcher of watchers) {
    watcher.close();
  }

  for (const client of clients) {
    client.end();
  }

  process.exit(0);
}
