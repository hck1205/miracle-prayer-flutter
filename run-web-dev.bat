@echo off
setlocal

if "%MIRACLE_PRAYER_GOOGLE_CLIENT_ID%"=="" (
  echo Set MIRACLE_PRAYER_GOOGLE_CLIENT_ID before running flutter dev.
  exit /b 1
)

echo Starting watched Flutter web dev server...
"C:\Program Files\nodejs\node.exe" watch-web-dev.js
