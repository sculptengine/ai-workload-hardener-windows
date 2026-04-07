@echo off
setlocal enabledelayedexpansion
echo.
echo [Step 0/5] Checking prerequisites...
echo ------------------------------------------------------------

set ERRORS=0

:: ── Check Windows version (must be Win 10/11) ──────────────────────────────
for /f "tokens=4-5 delims=. " %%i in ('ver') do set WIN_VER=%%i.%%j
echo [CHECK] Windows version: %WIN_VER%
ver | findstr /i "10\." >nul 2>&1
if errorlevel 1 (
    ver | findstr /i "11\." >nul 2>&1
    if errorlevel 1 (
        echo [WARN]  Windows 10 or 11 recommended. Older versions may have issues.
    )
)
echo [ OK ]  Windows version is compatible.

:: ── Check WSL2 ─────────────────────────────────────────────────────────────
echo.
echo [CHECK] Looking for WSL2 (required by Docker Desktop)...
wsl --status >nul 2>&1
if errorlevel 1 (
    echo [ !! ]  WSL2 not found. Docker Desktop needs it.
    echo.
    echo         HOW TO FIX:
    echo         1. Open PowerShell as Administrator
    echo         2. Run: wsl --install
    echo         3. Restart your computer
    echo         4. Run this script again
    echo.
    set ERRORS=1
) else (
    echo [ OK ]  WSL2 is installed.
)

:: ── Check Docker Desktop ────────────────────────────────────────────────────
echo.
echo [CHECK] Looking for Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ !! ]  Docker Desktop not found.
    echo.
    echo         HOW TO FIX:
    echo         1. Go to: https://www.docker.com/products/docker-desktop/
    echo         2. Click "Download for Windows"
    echo         3. Run the installer, click through, restart when asked
    echo         4. Open Docker Desktop from Start Menu, wait for it to say "Running"
    echo         5. Come back and run this script again
    echo.
    set ERRORS=1
) else (
    for /f "tokens=*" %%v in ('docker --version') do echo [ OK ]  %%v
)

:: ── Check Docker is actually running (not just installed) ───────────────────
if !ERRORS!==0 (
    echo.
    echo [CHECK] Checking if Docker engine is running...
    docker info >nul 2>&1
    if errorlevel 1 (
        echo [ !! ]  Docker is installed but not running.
        echo.
        echo         HOW TO FIX:
        echo         1. Open Docker Desktop from your Start Menu or taskbar
        echo         2. Wait until you see "Docker Desktop is running" 
        echo            (look for the whale icon in your system tray)
        echo         3. Run this script again
        echo.
        set ERRORS=1
    ) else (
        echo [ OK ]  Docker engine is running.
    )
)

:: ── Check Node.js (needed for Claude Code) ──────────────────────────────────
echo.
echo [CHECK] Looking for Node.js (needed for Claude Code)...
node --version >nul 2>&1
if errorlevel 1 (
    echo [ !! ]  Node.js not found.
    echo.
    echo         HOW TO FIX:
    echo         1. Go to: https://nodejs.org
    echo         2. Click the "LTS" download button (the left one)
    echo         3. Run the installer with all default settings
    echo         4. Close and reopen this window
    echo         5. Run this script again
    echo.
    set ERRORS=1
) else (
    for /f "tokens=*" %%v in ('node --version') do echo [ OK ]  Node.js %%v found.
)

:: ── Check / Install Claude Code ─────────────────────────────────────────────
echo.
echo [CHECK] Looking for Claude Code...
claude --version >nul 2>&1
if errorlevel 1 (
    echo [ -- ]  Claude Code not installed. Installing now...
    npm install -g @anthropic-ai/claude-code >nul 2>&1
    if errorlevel 1 (
        echo [ !! ]  Could not auto-install Claude Code.
        echo         Try manually: npm install -g @anthropic-ai/claude-code
        set ERRORS=1
    ) else (
        echo [ OK ]  Claude Code installed successfully.
    )
) else (
    for /f "tokens=*" %%v in ('claude --version') do echo [ OK ]  Claude Code %%v found.
)

:: ── Claude Pro login check ───────────────────────────────────────────────────
echo.
echo [CHECK] Checking Claude Code login status (Claude Pro)...
set CC_AUTH=%APPDATA%\Claude\claude_desktop_config.json
set CC_AUTH2=%USERPROFILE%\.claude.json
set CC_AUTH3=%USERPROFILE%\.claude\auth.json
if exist "%CC_AUTH%" (
    echo [ OK ]  Claude Code credentials found. Logged in via Claude Pro.
) else if exist "%CC_AUTH2%" (
    echo [ OK ]  Claude Code credentials found. Logged in via Claude Pro.
) else if exist "%CC_AUTH3%" (
    echo [ OK ]  Claude Code credentials found. Logged in via Claude Pro.
) else (
    echo [ -- ]  Claude Code credentials not found.
    echo.
    echo         HOW TO FIX:
    echo         1. Open a new terminal window
    echo         2. Run: claude
    echo         3. Select option 1 - Claude account with subscription
    echo         4. Log in with your Claude Pro account in the browser
    echo         5. Come back and run setup.bat again
    echo.
    set ERRORS=1
)

:: ── Final result ─────────────────────────────────────────────────────────────
echo.
if !ERRORS!==1 (
    echo [RESULT] Some prerequisites are missing. Fix the issues above and re-run setup.bat.
    exit /b 1
) else (
    echo [RESULT] All prerequisites are good. Moving to security setup...
    exit /b 0
)
