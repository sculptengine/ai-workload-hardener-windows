@echo off
setlocal enabledelayedexpansion
echo.
echo [Step 5/5] Running security posture check...
echo ------------------------------------------------------------

set SCORE=0
set MAX_SCORE=100
set REPORT=hardener-report.txt
set WORKSPACE=%USERPROFILE%\ai-workspace

:: Start report
(
echo ============================================================
echo   AI Workload Security Report
echo   Generated: %DATE% %TIME%
echo   Machine:   %COMPUTERNAME% / %USERNAME%
echo ============================================================
echo.
) > "%REPORT%"

:: ── Check 1: Docker running (20 pts) ──────────────────────────────────────────
echo [CHECK] Docker engine...
docker info >nul 2>&1
if not errorlevel 1 (
    echo [ OK ]  Docker is running.
    echo [PASS] Docker engine is running.  (+20 pts^) >> "%REPORT%"
    set /a SCORE+=20
) else (
    echo [ !! ]  Docker is NOT running.
    echo [FAIL] Docker engine is not running.  (0 pts^) >> "%REPORT%"
    echo        Fix: Open Docker Desktop and wait for it to start. >> "%REPORT%"
)

:: ── Check 2: Isolated network exists (20 pts) ─────────────────────────────────
echo [CHECK] Isolated Docker network...
docker network inspect ai-isolated >nul 2>&1
if not errorlevel 1 (
    echo [ OK ]  Isolated network "ai-isolated" exists.
    echo [PASS] Isolated Docker network exists.  (+20 pts^) >> "%REPORT%"
    set /a SCORE+=20
) else (
    echo [ !! ]  Isolated network not found.
    echo [FAIL] Isolated Docker network missing.  (0 pts^) >> "%REPORT%"
    echo        Fix: Run 01_network.bat >> "%REPORT%"
)

:: ── Check 3: No API keys in .env files (20 pts) ───────────────────────────────
echo [CHECK] API key exposure...
set KEY_LEAK=0
for %%d in ("%USERPROFILE%\Desktop" "%USERPROFILE%\Documents" "%CD%") do (
    if exist "%%~d" (
        for /r "%%~d" %%f in (.env .env.local) do (
            if exist "%%f" (
                findstr /i "sk-ant\|ANTHROPIC_API_KEY\|OPENAI_API_KEY" "%%f" >nul 2>&1
                if not errorlevel 1 set KEY_LEAK=1
            )
        )
    )
)
if "!KEY_LEAK!"=="0" (
    echo [ OK ]  No API keys found in .env files.
    echo [PASS] No API keys exposed in .env files.  (+20 pts^) >> "%REPORT%"
    set /a SCORE+=20
) else (
    echo [ !! ]  API keys found in .env files.
    echo [FAIL] API keys found in .env files.  (0 pts^) >> "%REPORT%"
    echo        Fix: Move keys to Windows Environment Variables. >> "%REPORT%"
)

:: ── Check 4: Claude Pro login (20 pts) ───────────────────────────────────────
echo [CHECK] Claude Code login (Claude Pro)...
set CC_AUTH=%APPDATA%\Claude\claude_desktop_config.json
set CC_AUTH2=%USERPROFILE%\.claude.json
set CC_AUTH3=%USERPROFILE%\.claude\auth.json
if exist "%CC_AUTH%" (
    set CC_LOGGED_IN=1
) else if exist "%CC_AUTH2%" (
    set CC_LOGGED_IN=1
) else if exist "%CC_AUTH3%" (
    set CC_LOGGED_IN=1
) else (
    set CC_LOGGED_IN=0
)
if "!CC_LOGGED_IN!"=="1" (
    echo [ OK ]  Claude Code credentials found. Logged in via Claude Pro.
    echo [PASS] Claude Code logged in via Claude Pro.  (+20 pts^) >> "%REPORT%"
    set /a SCORE+=20
) else (
    echo [ !! ]  Claude Code credentials not found.
    echo [FAIL] Claude Code not logged in.  (0 pts^) >> "%REPORT%"
    echo        Fix: Open a new terminal, run 'claude', select option 1 and log in. >> "%REPORT%"
)

:: ── Check 5: Workspace folder exists and is isolated (20 pts) ─────────────────
echo [CHECK] Isolated workspace folder...
if exist "%WORKSPACE%" (
    echo [ OK ]  Workspace folder exists at %WORKSPACE%
    echo [PASS] Isolated workspace folder configured.  (+20 pts^) >> "%REPORT%"
    set /a SCORE+=20
) else (
    echo [ !! ]  Workspace folder not found.
    echo [FAIL] Workspace folder not configured.  (0 pts^) >> "%REPORT%"
    echo        Fix: Run 02_isolate.bat >> "%REPORT%"
)

:: ── Bonus info: open ports ────────────────────────────────────────────────────
echo.
echo [INFO]  Checking open ports (informational)...
echo. >> "%REPORT%"
echo ── Open Listening Ports ─────────────────────────────────── >> "%REPORT%"
netstat -an | findstr "LISTENING" >> "%REPORT%"
echo. >> "%REPORT%"

:: ── Bonus info: running Docker containers ─────────────────────────────────────
echo [INFO]  Checking running containers...
echo ── Running Docker Containers ────────────────────────────── >> "%REPORT%"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" >> "%REPORT%" 2>nul
echo. >> "%REPORT%"

:: ── Final score ───────────────────────────────────────────────────────────────
echo. >> "%REPORT%"
echo ============================================================ >> "%REPORT%"
echo   SECURITY SCORE: %SCORE% / %MAX_SCORE% >> "%REPORT%"

if %SCORE% geq 80 (
    echo   RATING: GOOD - Your setup is well protected. >> "%REPORT%"
) else if %SCORE% geq 60 (
    echo   RATING: FAIR - Some issues need attention. >> "%REPORT%"
) else (
    echo   RATING: NEEDS WORK - Please fix the issues above. >> "%REPORT%"
)

echo ============================================================ >> "%REPORT%"
echo. >> "%REPORT%"
echo   Next steps: >> "%REPORT%"
echo   1. Start your AI tools: docker compose -f docker-compose.ai.yml up -d >> "%REPORT%"
echo   2. Open chat UI at:     http://localhost:3000 >> "%REPORT%"
echo   3. Run file monitor:    Right-click monitor.ps1 and Run with PowerShell >> "%REPORT%"
echo   4. Re-run this check monthly: bash 05_verify.bat >> "%REPORT%"
echo ============================================================ >> "%REPORT%"

:: ── Print summary to screen ───────────────────────────────────────────────────
echo.
echo ============================================================
echo   SECURITY SCORE: %SCORE% / %MAX_SCORE%
if %SCORE% geq 80 (
    echo   RATING: GOOD - Your setup is well protected.
) else if %SCORE% geq 60 (
    echo   RATING: FAIR - Some issues need attention.
) else (
    echo   RATING: NEEDS WORK - Please fix the issues listed above.
)
echo ============================================================
echo.
echo   Full report saved to: %REPORT%
echo   Open it with: notepad %REPORT%
echo.
