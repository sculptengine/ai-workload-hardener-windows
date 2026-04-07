@echo off
setlocal enabledelayedexpansion
echo.
echo [Step 3/5] Scanning for exposed API keys...
echo ------------------------------------------------------------

set LEAKS_FOUND=0

:: ── Scan common locations for hardcoded keys ──────────────────────────────────
echo [SCAN] Checking common locations for exposed API keys...
echo        (This does NOT send anything anywhere - runs locally only)
echo.

:: Check .env files in current directory and Desktop
for %%d in ("%USERPROFILE%\Desktop" "%USERPROFILE%\Documents" "%CD%") do (
    if exist "%%~d" (
        for /r "%%~d" %%f in (.env .env.local .env.development) do (
            if exist "%%f" (
                findstr /i "sk-ant\|ANTHROPIC_API_KEY\|sk-proj\|OPENAI_API_KEY" "%%f" >nul 2>&1
                if not errorlevel 1 (
                    echo [ !! ]  API key found in: %%f
                    echo         This file is not safe. Move your key to Environment Variables.
                    set LEAKS_FOUND=1
                )
            )
        )
    )
)

:: Check PowerShell profile for hardcoded keys
if exist "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" (
    findstr /i "sk-ant\|ANTHROPIC_API_KEY\|sk-proj" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
    if not errorlevel 1 (
        echo [ !! ]  API key found in your PowerShell profile.
        echo         Remove it and use Environment Variables instead.
        set LEAKS_FOUND=1
    )
)

:: Check if key is already safely in environment variables
if "!LEAKS_FOUND!"=="0" (
    echo [ OK ]  No hardcoded API keys found in common locations.
)

:: ── Claude Pro note ───────────────────────────────────────────────────────────
echo.
echo [KEYS] You are using Claude Pro - no API key needed.
echo        Claude Code authenticates via your browser login.
echo        Your credentials are stored safely by Claude Code itself.
echo.
echo        If you ever use the Anthropic API directly (for custom scripts etc.),
echo        store keys via Windows Environment Variables - NOT in .env files.
echo        Go to: Start Menu - search "Edit environment variables"
echo.

:: ── Check if git is tracking any .env files ───────────────────────────────────
git --version >nul 2>&1
if not errorlevel 1 (
    echo [SCAN] Checking if any .env files are tracked by git...
    git ls-files .env .env.local .env.* 2>nul | findstr /r "." >nul 2>&1
    if not errorlevel 1 (
        echo [ !! ]  WARNING: .env file is being tracked by git!
        echo         This means your keys could be in your git history.
        echo.
        echo         HOW TO FIX:
        echo         1. Add .env to your .gitignore file
        echo         2. Run: git rm --cached .env
        echo         3. Run: git commit -m "remove .env from tracking"
        echo         4. If already pushed to GitHub, rotate your keys NOW.
        set LEAKS_FOUND=1
    ) else (
        echo [ OK ]  No .env files tracked by git.
    )
)

:: ── Write a .gitignore template ────────────────────────────────────────────────
echo.
echo [KEYS] Writing .gitignore template to protect sensitive files...
if not exist ".gitignore" (
    (
    echo # AI Workload Hardener - safe defaults
    echo .env
    echo .env.local
    echo .env.development
    echo .env.production
    echo *.key
    echo *.pem
    echo hardener-report.txt
    echo docker-compose.override.yml
    ) > .gitignore
    echo [ OK ]  .gitignore created. Sensitive files will not be tracked by git.
) else (
    echo [ OK ]  .gitignore already exists. Make sure .env is in it.
)

echo.
echo [ OK ]  Secrets step complete.
if "!LEAKS_FOUND!"=="1" (
    echo [ !! ]  Action needed: Fix the key leaks listed above before continuing.
)
