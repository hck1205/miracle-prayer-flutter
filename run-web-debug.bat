@echo off
setlocal

if "%MIRACLE_PRAYER_GOOGLE_CLIENT_ID%"=="" (
  echo Set MIRACLE_PRAYER_GOOGLE_CLIENT_ID before running flutter dev.
  exit /b 1
)

if "%MIRACLE_PRAYER_WEB_HOST%"=="" set MIRACLE_PRAYER_WEB_HOST=localhost
if "%MIRACLE_PRAYER_WEB_PORT%"=="" set MIRACLE_PRAYER_WEB_PORT=5173
if "%MIRACLE_PRAYER_BACKEND_BASE_URL%"=="" set MIRACLE_PRAYER_BACKEND_BASE_URL=http://127.0.0.1:3000/api

set MIRACLE_PRAYER_FLUTTER_BIN_WINDOWS=C:\Workspace\miracle-prayer\.tooling\flutter-sdk\bin\flutter.bat

echo Starting watched Flutter web debug session...
"C:\Program Files\nodejs\node.exe" watch-flutter-dev.js
