const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

const projectRoot = __dirname;
const flutterBin =
  process.env.MIRACLE_PRAYER_FLUTTER_BIN_WINDOWS ||
  "C:\\Workspace\\miracle-prayer\\.tooling\\flutter-sdk\\bin\\flutter.bat";
const host = process.env.MIRACLE_PRAYER_WEB_HOST || "localhost";
const port = process.env.MIRACLE_PRAYER_WEB_PORT || "5173";
const backendBaseUrl =
  process.env.MIRACLE_PRAYER_BACKEND_BASE_URL || "http://127.0.0.1:3000/api";
const googleClientId = process.env.MIRACLE_PRAYER_GOOGLE_CLIENT_ID || "";
const googleServerClientId =
  process.env.MIRACLE_PRAYER_GOOGLE_SERVER_CLIENT_ID || "";

if (!googleClientId) {
  console.error(
    "Set MIRACLE_PRAYER_GOOGLE_CLIENT_ID before running flutter dev.",
  );
  process.exit(1);
}

const watchTargets = [
  "lib",
  "web",
  "assets",
  "test",
  "pubspec.yaml",
  "pubspec.lock",
].map((target) => path.resolve(projectRoot, target));

const watchers = [];
let reloadTimer = null;
let pendingReload = null;
let childClosed = false;

const child = spawn(flutterBin, buildFlutterArgs(), {
  cwd: projectRoot,
  env: process.env,
  stdio: ["pipe", "inherit", "inherit"],
  windowsHide: false,
  shell: true,
});

console.log("[dev] Flutter web debug is starting...");
console.log(`[dev] Watching files for changes at http://${host}:${port}`);
console.log("[dev] Save files to auto reload. Press q to quit.");

setupStdinForwarding();
setupWatchers();

child.on("exit", (code) => {
  childClosed = true;
  cleanup();
  process.exit(code ?? 0);
});

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

function buildFlutterArgs() {
  const parts = [
    "run",
    "-d",
    "chrome",
    `--web-hostname=${host}`,
    `--web-port=${port}`,
    `--dart-define=GOOGLE_CLIENT_ID=${googleClientId}`,
    `--dart-define=BACKEND_BASE_URL=${backendBaseUrl}`,
  ];

  if (googleServerClientId) {
    parts.push(
      `--dart-define=GOOGLE_SERVER_CLIENT_ID=${googleServerClientId}`,
    );
  }

  return parts;
}

function setupWatchers() {
  for (const target of watchTargets) {
    if (!fs.existsSync(target)) {
      continue;
    }

    const stats = fs.statSync(target);
    const watcher = fs.watch(
      target,
      { recursive: stats.isDirectory() },
      (_, filename) => {
        const changedPath = normalizeChangedPath(target, filename);

        if (!changedPath || shouldIgnore(changedPath)) {
          return;
        }

        const reloadType = requiresRestart(changedPath) ? "R" : "r";
        scheduleReload(reloadType, changedPath);
      },
    );

    watcher.on("error", (error) => {
      console.error(`[dev] Watcher error for ${target}:`, error.message);
    });

    watchers.push(watcher);
  }
}

function normalizeChangedPath(target, filename) {
  if (!filename) {
    return target;
  }

  return path.resolve(target, String(filename));
}

function shouldIgnore(changedPath) {
  return (
    changedPath.includes(`${path.sep}.dart_tool${path.sep}`) ||
    changedPath.includes(`${path.sep}build${path.sep}`) ||
    changedPath.includes(`${path.sep}.git${path.sep}`) ||
    changedPath.endsWith(`${path.sep}.DS_Store`)
  );
}

function requiresRestart(changedPath) {
  const relativePath = path.relative(projectRoot, changedPath).replace(/\\/g, "/");

  return (
    relativePath === "pubspec.yaml" ||
    relativePath === "pubspec.lock" ||
    relativePath.startsWith("assets/") ||
    relativePath.startsWith("web/")
  );
}

function scheduleReload(reloadType, changedPath) {
  pendingReload = pendingReload === "R" ? "R" : reloadType;

  if (reloadTimer !== null) {
    clearTimeout(reloadTimer);
  }

  reloadTimer = setTimeout(() => {
    reloadTimer = null;
    triggerReload(pendingReload || "r", changedPath);
    pendingReload = null;
  }, 250);
}

function triggerReload(reloadType, changedPath) {
  if (childClosed || !child.stdin.writable) {
    return;
  }

  const relativePath = path.relative(projectRoot, changedPath).replace(/\\/g, "/");
  const label = reloadType === "R" ? "hot restart" : "hot reload";
  console.log(`[dev] ${label}: ${relativePath}`);
  child.stdin.write(`${reloadType}\n`);
}

function setupStdinForwarding() {
  if (!process.stdin.isTTY) {
    return;
  }

  process.stdin.setEncoding("utf8");
  process.stdin.resume();
  process.stdin.on("data", (chunk) => {
    if (childClosed || !child.stdin.writable) {
      return;
    }

    child.stdin.write(chunk);
  });
}

function shutdown() {
  cleanup();

  if (!childClosed) {
    child.kill();
  }
}

function cleanup() {
  if (reloadTimer !== null) {
    clearTimeout(reloadTimer);
    reloadTimer = null;
  }

  for (const watcher of watchers) {
    watcher.close();
  }
}
