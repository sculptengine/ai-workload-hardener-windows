# 🛡️ AI Workload Hardener for Windows

> Secure your local AI setup in under 10 minutes.

If you're running **Claude Code**, **Ollama**, or any local AI tools on Windows, this toolkit locks down your environment so a rogue agent or misconfigured tool can't touch your files, SSH keys, or credentials.

No security background needed. Double-click and follow the prompts.

---

## The problem this solves

Most people running local AI tools on Windows are unknowingly exposed:

- Claude Code has shell access — if your network is flat, lateral movement is trivial
- API keys sitting in `.env` files get picked up by git and leaked to GitHub
- Local models running in Docker often have access to your entire file system
- No logging means you have no idea what your AI agent actually did

This toolkit fixes all of that automatically.

---

## What's inside

| Script | What it does |
|---|---|
| `setup.bat` | Runs all steps in order. Double-click to start. |
| `00_prerequisites.bat` | Checks Docker, WSL2, Node.js, Claude Code. Installs what's missing. |
| `01_network.bat` | Creates isolated Docker networks. AI containers cannot reach your other devices. |
| `02_isolate.bat` | Creates a safe workspace folder. Writes a hardened Docker Compose template. |
| `03_secrets.bat` | Scans for exposed API keys in .env files. Checks git tracking. |
| `04_filesystem.bat` | Enables Windows audit logging. Writes a file monitor for sensitive paths. |
| `05_verify.bat` | Runs a full posture check and gives you a score out of 100. |

---

## Requirements

- Windows 10 or 11
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — install this first
- WSL2 — run `wsl --install` in PowerShell as Administrator if you don't have it
- Claude Pro subscription or Anthropic API key

The setup script checks for everything and gives you exact fix instructions if anything is missing.

---

## Quick start

```powershell
# 1. Clone the repo
git clone https://github.com/yourusername/ai-workload-hardener-windows.git
cd ai-workload-hardener-windows

# 2. Run setup
.\setup.bat
```

Or download the ZIP, unzip to your Desktop, and double-click `setup.bat`.

---

## After setup

**Start your AI tools:**
```powershell
docker compose -f docker-compose.ai.yml up -d
```

**Open the chat interface:**
```
http://localhost:3000
```

**Run the file monitor (optional but recommended):**
Right-click `monitor.ps1` and select Run with PowerShell.

**Check your score anytime:**
```powershell
.\05_verify.bat
```

---

## What gets created

```
C:\Users\<you>\ai-workspace\     <- the only folder AI tools can touch
docker-compose.ai.yml            <- hardened Ollama + Open WebUI setup
monitor.ps1                      <- background file access monitor
hardener-report.txt              <- your security score and findings
```

---

## Architecture

```
Your Windows Machine
|
+-- Claude Code (native)
|   +-- talks to containers via localhost ports
|
+-- Docker (isolated)
    +-- Ollama        -> localhost:11434  (local AI models)
    +-- Open WebUI    -> localhost:3000   (browser chat UI)
    +-- ai-workspace  -> shared volume   (only writable path)

Networks:
  ai-isolated  -> no internet, containers talk to each other only
  ai-external  -> internet access, for model downloads only
```

---

## Security checks (scored out of 100)

| Check | Points |
|---|---|
| Docker engine running | 20 |
| Isolated Docker network exists | 20 |
| No API keys in .env files | 20 |
| Claude Code logged in securely | 20 |
| Isolated workspace folder configured | 20 |

A score of **80+** means your setup is well protected. Run `05_verify.bat` monthly to make sure it stays that way.

---

## What it does NOT do

- Does not install software without telling you
- Does not send any data anywhere — everything runs locally
- Does not touch files outside the workspace folder
- Cannot configure your router or WiFi — see [CHECKLIST.md](CHECKLIST.md) for manual steps

---

## Manual steps (after running the scripts)

Some things cannot be scripted. See [CHECKLIST.md](CHECKLIST.md) for:

- WiFi and router segmentation (biggest single improvement you can make)
- API key rotation schedule
- Docker Desktop security settings
- Backup strategy for your workspace

---

## Troubleshooting

**`setup.bat` not recognized**
You are in PowerShell. Use `.\setup.bat` instead of `setup.bat`.

**Docker not found**
Install [Docker Desktop](https://www.docker.com/products/docker-desktop/), open it, wait for the whale icon in your system tray, then run the script again.

**WSL2 error**
Open PowerShell as Administrator and run `wsl --install`, then restart your computer.

**`docker-compose.ai.yml` not found**
Run `.\02_isolate.bat` first — it generates this file.

**Score below 80**
Open `hardener-report.txt` — every failing check includes a specific fix instruction.

---

## Run monthly

Your score drifts as you install new tools. Run `05_verify.bat` once a month to make sure your setup is still healthy.

---

## Contributing

Issues and PRs welcome. Kept intentionally simple — the goal is something a non-security person can run and understand.

---

## License

MIT

---

> New to Docker or local AI tools? Start with the **[Getting Started Guide](GETTING-STARTED.md)** — no technical background needed.
 
---
*Built by a Senior Security Engineer who got tired of seeing local AI setups with zero hardening.*
