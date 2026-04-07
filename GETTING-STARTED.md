# Getting Started Guide
### No technical background needed

This guide walks you through setting up and using the AI Workload Hardener from scratch.
Everything here is **free**. No subscriptions, no cloud services, no hidden costs.

---

## Before we start — what is this actually doing?

When you run AI tools like Claude Code or Ollama on your Windows PC, they have more
access to your computer than most people realise. This toolkit puts a security fence
around those tools so they can only touch what you allow.

Think of it like this:

```
Without this toolkit:          With this toolkit:
                               
Your PC                        Your PC
+-- AI tools                   +-- AI tools (fenced off)
+-- Your Documents        vs.  |   +-- can only touch ai-workspace folder
+-- Your SSH keys              +-- Your Documents      (protected)
+-- Everything else            +-- Your SSH keys       (protected)
                               +-- Everything else     (protected)
```

Everything runs on your machine. Nothing is sent to any server. It is completely free.

---

## What you need before starting

You need to install two things manually. The toolkit handles everything else.

### 1. Docker Desktop (free)
This is the "fence" that keeps AI tools isolated.

1. Go to **https://www.docker.com/products/docker-desktop/**
2. Click **Download for Windows**
3. Run the installer — click through with all default settings
4. Restart your computer when asked
5. After restart, open **Docker Desktop** from your Start Menu
6. Wait until you see a whale icon in your system tray (bottom right of screen)
7. It should say **"Docker Desktop is running"**

> Docker Desktop is free for personal use.

### 2. WSL2 (free, built into Windows)
This is a Windows feature that Docker needs to run.

1. Click the **Start Menu**
2. Search for **PowerShell**
3. Right-click it and select **Run as administrator**
4. Type this and press Enter:
   ```
   wsl --install
   ```
5. Restart your computer when it finishes

> If it says WSL is already installed, you're good — skip this step.

---

## How to download this toolkit

**Option A — Download ZIP (easiest)**

1. On this GitHub page, click the green **Code** button at the top
2. Click **Download ZIP**
3. Find the ZIP in your Downloads folder
4. Right-click it and select **Extract All**
5. Move the extracted folder to your **Desktop**

**Option B — Git clone (if you use git)**
```powershell
git clone https://github.com/sculptengine/ai-workload-hardener-windows.git
```

---

## How to run the setup (one time only)

### Step 1 — Make sure Docker Desktop is open and running
Look for the whale icon in your system tray. If it is not there, open Docker Desktop from the Start Menu and wait for it to start.

### Step 2 — Open a terminal in the toolkit folder
1. Open the **ai-workload-hardener-windows** folder on your Desktop
2. Click once on the address bar at the top of the folder window
3. Type `powershell` and press **Enter**
4. A blue/black terminal window opens — you are in the right place

### Step 3 — Run the setup
Type this and press Enter:
```powershell
.\setup.bat
```

The script will now run through 5 steps automatically. You will see messages like:
```
[ OK ]  Docker is running.
[ OK ]  Network "ai-isolated" created.
[ OK ]  Workspace folder created at: C:\Users\yourname\ai-workspace
[ OK ]  No API keys found in .env files.
```

If you see `[ !! ]` instead of `[ OK ]`, the script will tell you exactly what to do to fix it.

### Step 4 — Check your score
At the end you will see:
```
SECURITY SCORE: 100 / 100
RATING: GOOD - Your setup is well protected.
```

A score of 80 or above means you are good to go.

> The full report is saved in **hardener-report.txt** in the same folder.
> Open it with Notepad anytime.

---

## How to start your AI tools

After setup is complete, run this every time you want to use your local AI tools:

```powershell
docker compose -f docker-compose.ai.yml up -d
```

Wait about 30 seconds, then open your browser and go to:
```
http://localhost:3000
```

You will see **Open WebUI** — a chat interface similar to ChatGPT, running completely
on your own computer for free.

### Pull your first AI model
1. Inside Open WebUI, click your profile icon (top right)
2. Go to **Admin Panel → Models**
3. In the model name box type `llama3.2` and click the download button
4. Wait for it to download (about 2GB, takes a few minutes)
5. Go back to the chat and select `llama3.2` from the model dropdown
6. Start chatting — everything runs locally, nothing leaves your machine

---

## How to stop everything

When you are done and want to shut down:

```powershell
docker compose -f docker-compose.ai.yml down
```

Then right-click the **whale icon** in your system tray and click **Quit Docker Desktop**.

Your models and data are saved. Next time you start up, everything picks up where you left off.

---

## How to start again next time

1. Open Docker Desktop from Start Menu, wait for it to say running
2. Open PowerShell in the toolkit folder (same as Step 2 above)
3. Run:
   ```powershell
   docker compose -f docker-compose.ai.yml up -d
   ```
4. Open `http://localhost:3000` in your browser

That is it. The full setup only runs once. After that, starting and stopping takes less than a minute.

---

## Frequently asked questions

**Is this really free?**
Yes. Docker Desktop is free for personal use. Ollama is free and open source.
Open WebUI is free and open source. This toolkit is free and open source.
The AI models you download (like Llama) are free. Nothing here costs money.

**Does anything get sent to the internet?**
The AI models run 100% on your machine. Your conversations never leave your computer.
The only internet traffic is when you first download a model — after that, everything is offline.

**Will this slow down my computer?**
Running a local AI model uses RAM and CPU. A basic model like `llama3.2` needs about 8GB of RAM.
When Docker is not running, there is zero impact on your computer.

**What is the ai-workspace folder?**
It is a folder created at `C:\Users\yourname\ai-workspace`. This is the only place
AI tools are allowed to read and write files. Think of it as the AI's sandbox.
Your Documents, Desktop, and other folders are not accessible to the AI tools.

**What if I get a score below 80?**
Open `hardener-report.txt` — each failing check has a specific fix written next to it.
Fix those items and run `.\05_verify.bat` again to recheck.

**How do I update the toolkit?**
Download the latest ZIP from GitHub and replace your existing folder.
Your models and data are stored in Docker volumes — they are not inside the toolkit folder,
so replacing the folder does not delete anything.

**Something broke. What do I do?**
Open an issue on GitHub with a screenshot of the error. Include what step you were on.

---

## What each file does

| File | Purpose |
|---|---|
| `setup.bat` | Runs everything in order. Start here. |
| `00_prerequisites.bat` | Checks and installs what is needed |
| `01_network.bat` | Sets up isolated Docker networks |
| `02_isolate.bat` | Creates workspace folder and Docker Compose file |
| `03_secrets.bat` | Scans for exposed API keys |
| `04_filesystem.bat` | Enables audit logging and file monitor |
| `05_verify.bat` | Security score check — run this monthly |
| `monitor.ps1` | Background file watcher (optional) |
| `docker-compose.ai.yml` | Docker configuration (created by setup) |
| `hardener-report.txt` | Your security score report (created by setup) |
| `CHECKLIST.md` | Manual steps for router and WiFi setup |

---

## Monthly maintenance (5 minutes)

Run this once a month to make sure your setup is still healthy:

```powershell
.\05_verify.bat
```

Check that your score is still 80 or above. That is all.

---

*This toolkit was built by a Senior Security Engineer. It is open source and free forever.*
*Found a bug or want to suggest an improvement? Open an issue on GitHub.*
