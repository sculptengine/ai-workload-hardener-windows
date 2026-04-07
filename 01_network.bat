@echo off
setlocal enabledelayedexpansion
echo.
echo [Step 1/5] Setting up isolated network for AI tools...
echo ------------------------------------------------------------

:: ── Create isolated Docker bridge network ────────────────────────────────────
echo [NET]  Creating isolated Docker network "ai-isolated"...
docker network inspect ai-isolated >nul 2>&1
if errorlevel 1 (
    docker network create --driver bridge --internal ai-isolated >nul 2>&1
    if errorlevel 1 (
        echo [ !! ]  Could not create isolated network.
        echo         Make sure Docker Desktop is running and try again.
    ) else (
        echo [ OK ]  Network "ai-isolated" created.
        echo         Your AI containers will run inside this network.
        echo         They CANNOT reach the internet unless you explicitly allow it.
    )
) else (
    echo [ OK ]  Network "ai-isolated" already exists. Skipping.
)

:: ── Create an external-access network for tools that need internet ────────────
echo.
echo [NET]  Creating "ai-external" network for tools that need internet...
docker network inspect ai-external >nul 2>&1
if errorlevel 1 (
    docker network create --driver bridge ai-external >nul 2>&1
    echo [ OK ]  Network "ai-external" created.
    echo         Use this ONLY for containers that must reach the internet.
    echo         Example: downloading a model from HuggingFace.
) else (
    echo [ OK ]  Network "ai-external" already exists. Skipping.
)

:: ── Write Windows Firewall rules ──────────────────────────────────────────────
echo.
echo [NET]  Checking Windows Firewall status...
netsh advfirewall show currentprofile state | findstr "ON" >nul 2>&1
if errorlevel 1 (
    echo [ !! ]  Windows Firewall appears to be off.
    echo         It is strongly recommended to keep it on.
    echo         Enable it: Start Menu → Windows Security → Firewall
) else (
    echo [ OK ]  Windows Firewall is active.
)

:: ── Print WiFi segmentation guide ─────────────────────────────────────────────
echo.
echo [NET]  WiFi segmentation (manual step - your router):
echo        For best security, put your AI workstation on a separate WiFi network.
echo        Most modern routers support a "Guest Network" - use that.
echo.
echo        Steps for most routers:
echo        1. Open your router admin page (usually 192.168.1.1 or 192.168.0.1)
echo        2. Look for "Guest Network" or "WiFi Isolation"
echo        3. Enable it and connect your AI workstation to that network
echo        4. This stops your AI tools from seeing your phones, smart TVs, etc.
echo.
echo [ OK ]  Network step complete.
