@echo off
setlocal enabledelayedexpansion
echo.
echo [Step 2/5] Setting up isolated workspace and Docker containers...
echo ------------------------------------------------------------

:: Create workspace folder
set WORKSPACE=%USERPROFILE%\ai-workspace
if not exist "%WORKSPACE%" (
    mkdir "%WORKSPACE%"
    echo [ OK ]  Workspace folder created at: %WORKSPACE%
    echo         This is the ONLY folder your AI tools can read and write.
) else (
    echo [ OK ]  Workspace folder already exists at: %WORKSPACE%
)

:: Write the PowerShell helper script first, then run it
echo.
echo [ISO]  Writing secure Docker Compose template...

:: Write the helper ps1 to a temp file
set PS1=%TEMP%\write_compose.ps1
(
echo $ws = $env:USERPROFILE + "/ai-workspace"
echo $yaml = "version: '3.9'`n"
echo $yaml += "networks:`n"
echo $yaml += "  ai-isolated:`n"
echo $yaml += "    external: true`n"
echo $yaml += "  ai-external:`n"
echo $yaml += "    external: true`n"
echo $yaml += "`n"
echo $yaml += "services:`n"
echo $yaml += "  ollama:`n"
echo $yaml += "    image: ollama/ollama:latest`n"
echo $yaml += "    container_name: ollama`n"
echo $yaml += "    ports:`n"
echo $yaml += "      - '11434:11434'`n"
echo $yaml += "    volumes:`n"
echo $yaml += "      - ollama-models:/root/.ollama`n"
echo $yaml += "      - '$ws/workspace:/workspace:rw'`n"
echo $yaml += "    networks:`n"
echo $yaml += "      - ai-external`n"
echo $yaml += "    restart: unless-stopped`n"
echo $yaml += "    security_opt:`n"
echo $yaml += "      - no-new-privileges:true`n"
echo $yaml += "`n"
echo $yaml += "  open-webui:`n"
echo $yaml += "    image: ghcr.io/open-webui/open-webui:main`n"
echo $yaml += "    container_name: open-webui`n"
echo $yaml += "    ports:`n"
echo $yaml += "      - '3000:8080'`n"
echo $yaml += "    volumes:`n"
echo $yaml += "      - open-webui-data:/app/backend/data`n"
echo $yaml += "    networks:`n"
echo $yaml += "      - ai-isolated`n"
echo $yaml += "    depends_on:`n"
echo $yaml += "      - ollama`n"
echo $yaml += "    environment:`n"
echo $yaml += "      - OLLAMA_BASE_URL=http://ollama:11434`n"
echo $yaml += "    restart: unless-stopped`n"
echo $yaml += "    security_opt:`n"
echo $yaml += "      - no-new-privileges:true`n"
echo $yaml += "`n"
echo $yaml += "volumes:`n"
echo $yaml += "  ollama-models:`n"
echo $yaml += "  open-webui-data:`n"
echo $yaml ^| Out-File -FilePath "docker-compose.ai.yml" -Encoding UTF8
) > "%PS1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del "%PS1%"

if exist "docker-compose.ai.yml" (
    echo [ OK ]  docker-compose.ai.yml written successfully.
) else (
    echo [ !! ]  Failed to write docker-compose.ai.yml
    exit /b 1
)

echo.
echo [ISO]  To start your AI tools later, run:
echo        docker compose -f docker-compose.ai.yml up -d
echo.
echo [ISO]  Then open http://localhost:3000 in your browser.
echo.
echo [ OK ]  Isolation step complete.
