$root = "C:\Workspace\miracle-prayer\miracle-prayer-flutter\build\web"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:5173/")
$listener.Start()

$mimeTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".png" = "image/png"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".svg" = "image/svg+xml"
  ".wasm" = "application/wasm"
  ".ico" = "image/x-icon"
  ".txt" = "text/plain; charset=utf-8"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relativePath = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))

    if ([string]::IsNullOrWhiteSpace($relativePath)) {
      $relativePath = "index.html"
    }

    $requestedPath = Join-Path $root $relativePath
    $resolvedPath = [System.IO.Path]::GetFullPath($requestedPath)

    if (-not $resolvedPath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $context.Response.StatusCode = 403
      $context.Response.Close()
      continue
    }

    if ((Test-Path $resolvedPath) -and (Get-Item $resolvedPath).PSIsContainer) {
      $resolvedPath = Join-Path $resolvedPath "index.html"
    }

    if (-not (Test-Path $resolvedPath)) {
      $resolvedPath = Join-Path $root "index.html"
    }

    $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
    $extension = [System.IO.Path]::GetExtension($resolvedPath).ToLowerInvariant()
    $context.Response.ContentType = $mimeTypes[$extension]

    if (-not $context.Response.ContentType) {
      $context.Response.ContentType = "application/octet-stream"
    }

    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.OutputStream.Close()
    $context.Response.Close()
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
