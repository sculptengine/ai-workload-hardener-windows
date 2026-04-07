# Manual Security Checklist
# Steps the script cannot do for you — do these once after running setup.bat

---

## Router / WiFi  [ ]

The biggest single improvement you can make.

- [ ] Log into your router admin page (usually http://192.168.1.1 or http://192.168.0.1)
- [ ] Enable "Guest Network" or a separate SSID
- [ ] Connect your AI workstation to that network
- [ ] Enable "AP Isolation" or "Client Isolation" if your router supports it
      (this stops devices on the same WiFi from talking to each other)
- [ ] Do NOT connect your phone, smart TV, or IoT devices to this network

Why: If Claude Code or Ollama is ever compromised, it should not be able to
scan or reach your other home devices.

---

## API Key Rotation  [ ]

- [ ] Set a reminder to rotate your Anthropic API key every 30 days
      Go to: https://console.anthropic.com → API Keys → Create new key
- [ ] Delete old keys after rotating
- [ ] If you ever accidentally paste a key into a file or chat, rotate it immediately

---

## Docker Desktop settings  [ ]

- [ ] Open Docker Desktop → Settings → Resources → File Sharing
      Make sure ONLY your workspace folder is shared, not your entire C: drive
- [ ] Settings → General → "Start Docker Desktop when you log in"
      Enable this so Docker is always ready
- [ ] Settings → General → "Send usage statistics" — disable if you prefer privacy

---

## Windows Defender  [ ]

- [ ] Open Windows Security → Virus & threat protection
- [ ] Make sure Real-time protection is ON
- [ ] Add your workspace folder as an exclusion ONLY if scans are slowing down
      your AI tools (most people don't need this)

---

## Backups  [ ]

- [ ] Your ai-workspace folder is the only place Claude Code writes files
      Back it up regularly — use OneDrive, Google Drive, or an external drive
- [ ] Docker volumes (model files, Open WebUI data) are inside Docker
      Back these up with: docker run --rm -v ollama-models:/data -v %CD%:/backup
      alpine tar czf /backup/ollama-backup.tar.gz /data

---

## Monthly checks  [ ]

- [ ] Run 05_verify.bat and check your score is still 80+
- [ ] Review your open ports: netstat -an | findstr LISTENING
- [ ] Check your AI workload logs at: %USERPROFILE%\ai-workload-logs\
- [ ] Update Docker images: docker compose -f docker-compose.ai.yml pull

---

Score yourself:
  5/5 done  = Excellent
  4/5 done  = Good
  3/5 done  = Fair — finish the router and key rotation steps
  2/5 done  = Needs work
