const http = require("http");
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "build/web");
const host = process.env.MIRACLE_PRAYER_WEB_HOST || "localhost";
const port = Number(process.env.MIRACLE_PRAYER_WEB_PORT || "5173");
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

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent((req.url || "/").split("?")[0]);
  let filePath = path.join(
    root,
    urlPath === "/" ? "index.html" : urlPath.replace(/^\//, ""),
  );

  if (!filePath.startsWith(root)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, "index.html");
  }

  if (!fs.existsSync(filePath)) {
    filePath = path.join(root, "index.html");
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(500);
      res.end(String(err));
      return;
    }

    res.writeHead(200, {
      "Content-Type":
        mime[path.extname(filePath).toLowerCase()] || "application/octet-stream",
    });
    res.end(data);
  });
});

server.listen(port, host, () => {
  console.log(`Miracle Prayer web build is available at http://${host}:${port}`);
});

server.on("error", (error) => {
  console.error(error);
  process.exit(1);
});
