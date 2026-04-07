@echo off
setlocal enabledelayedexpansion
title AI Workload Hardener for Windows

echo.
echo ============================================================
echo   AI Workload Hardener for Windows
echo   Secures your local AI tools (Claude Code, Ollama, etc.)
echo ============================================================
echo.
echo This script will:
echo   [1] Check and guide Docker Desktop installation
echo   [2] Create an isolated network for your AI tools
echo   [3] Set up a safe low-privilege user for AI workloads
echo   [4] Scan for exposed API keys
echo   [5] Lock down filesystem access
echo   [6] Run a full security check and give you a score
echo.
echo Press any key to start, or close this window to cancel.
pause >nul

echo.
echo Starting security setup...
echo.

call 00_prerequisites.bat
if errorlevel 1 (
    echo.
    echo [ERROR] Prerequisites check failed. Fix the above issues and run setup.bat again.
    pause
    exit /b 1
)

call 01_network.bat
call 02_isolate.bat
call 03_secrets.bat
call 04_filesystem.bat
call 05_verify.bat

echo.
echo ============================================================
echo   Setup complete! Your report is saved in hardener-report.txt
echo   Open it with: notepad hardener-report.txt
echo ============================================================
echo.
pause
