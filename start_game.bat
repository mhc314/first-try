@echo off
setlocal
set "GAME_DIR=%~dp0"
set "GODOT_EXE=%GAME_DIR%tools\godot\Godot_v4.6.1-stable_win64.exe"
if not exist "%GODOT_EXE%" (
  echo Godot was not found at: %GODOT_EXE%
  echo See README.md for setup instructions.
  pause
  exit /b 1
)
if not exist "%GAME_DIR%tools\tmp" mkdir "%GAME_DIR%tools\tmp"
if not exist "%GAME_DIR%tools\user-data" mkdir "%GAME_DIR%tools\user-data"
if not exist "%GAME_DIR%tools\user-cache" mkdir "%GAME_DIR%tools\user-cache"
set "TEMP=%GAME_DIR%tools\tmp"
set "TMP=%GAME_DIR%tools\tmp"
set "APPDATA=%GAME_DIR%tools\user-data"
set "LOCALAPPDATA=%GAME_DIR%tools\user-cache"
start "Photography Lab" "%GODOT_EXE%" --path "%GAME_DIR%."
endlocal
