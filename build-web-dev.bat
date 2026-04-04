@echo off
setlocal

if "%MIRACLE_PRAYER_GOOGLE_CLIENT_ID%"=="" (
  echo Set MIRACLE_PRAYER_GOOGLE_CLIENT_ID before building the Flutter web app.
  exit /b 1
)

if "%MIRACLE_PRAYER_WEB_HOST%"=="" set MIRACLE_PRAYER_WEB_HOST=localhost
if "%MIRACLE_PRAYER_WEB_PORT%"=="" set MIRACLE_PRAYER_WEB_PORT=5173
if "%MIRACLE_PRAYER_BACKEND_BASE_URL%"=="" set MIRACLE_PRAYER_BACKEND_BASE_URL=http://127.0.0.1:3000/api

set FLUTTER_ROOT=C:\Users\CkHong\.puro\envs\miracle-prayer\flutter
set DART_BIN=%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\dart.exe
set FLUTTER_TOOLS=%FLUTTER_ROOT%\packages\flutter_tools\bin\flutter_tools.dart

echo Building Flutter web app...
"%DART_BIN%" "%FLUTTER_TOOLS%" build web --release ^
  --dart-define=GOOGLE_CLIENT_ID=%MIRACLE_PRAYER_GOOGLE_CLIENT_ID% ^
  --dart-define=BACKEND_BASE_URL=%MIRACLE_PRAYER_BACKEND_BASE_URL%
