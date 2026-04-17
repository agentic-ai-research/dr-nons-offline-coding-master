# Troubleshooting

Every error encountered during real-world setup — and exactly how to fix it.

---

## VS Code / Continue.dev Errors

### "Language model unavailable"

**What it means:** Continue.dev can't reach Ollama.

**Fix:**
```bash
ollama serve
```
Leave that terminal open and retry. If you want it to auto-start permanently:
```bash
brew services start ollama
```

---

### "Unable to resolve chat model with family selection: copilot-base"

**What it means:** Continue's "New Experience" (NE) mode is enabled. It tries to use GitHub Copilot as a base — even when you have local models selected.

**Fix — add to VS Code settings (Cmd+Shift+P → "Open User Settings JSON"):**
```json
"continue.enableNewExperience": false,
"continue.showInlineTip": false
```
Reload VS Code. The error disappears.

**Why this happens:** Newer versions of Continue added an experimental "New Experience" mode that routes through VS Code's Language Model API, which defaults to GitHub Copilot. The local model dropdown in that mode is misleading — it doesn't actually bypass the Copilot requirement.

---

### `deepseek-r1:7b does not support tools`

**What it means:** Your Continue config has tool-calling enabled for DeepSeek R1, but that model doesn't support it.

**Fix — in `~/.continue/config.json`, add `capabilities` to the DeepSeek entry:**
```json
{
  "title": "DeepSeek R1 7B (Reasoning)",
  "provider": "ollama",
  "model": "deepseek-r1:7b",
  "apiBase": "http://localhost:11434",
  "contextLength": 131072,
  "completionOptions": { "temperature": 0.1, "maxTokens": 4096 },
  "capabilities": { "tools": false }
}
```

---

### Cmd+L does nothing in VS Code

**Cause 1:** Continue.dev isn't installed.
```bash
code --install-extension Continue.continue
```
Restart VS Code.

**Cause 2:** `code` CLI isn't in your PATH.
- Open VS Code
- Press Cmd+Shift+P
- Type: `Shell Command: Install 'code' command in PATH`
- Hit Enter, enter your password
- Open a new terminal and retry

---

### Continue shows model dropdown but model responds with raw JSON like:
```json
{"name": "read_skill", "arguments": {"skillName": "greeting"}}
```

**What it means:** You're in the OpenClaw chat panel, not Continue.dev. OpenClaw's agent is intercepting the message and trying to call a skill.

**Fix:** Press Cmd+L (not clicking the right-side chat panel). Cmd+L always opens Continue.dev.

---

### Continue autocomplete not working (no Tab suggestions)

**Check 1:** Make sure Ollama is running (`brew services list | grep ollama`)

**Check 2:** Verify `tabAutocompleteModel` is set in `~/.continue/config.json`:
```json
"tabAutocompleteModel": {
  "title": "Qwen Coder (Autocomplete)",
  "provider": "ollama",
  "model": "qwen2.5-coder:7b",
  "apiBase": "http://localhost:11434"
}
```

**Check 3:** In VS Code settings, make sure `continue.enableTabAutocomplete` is `true`.

---

## Ollama Errors

### `command not found: ollama`

**Cause:** Ollama installed but not in PATH.

**Fix:**
```bash
# Apple Silicon Mac:
export PATH="/opt/homebrew/bin:$PATH"
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile

# Intel Mac:
export PATH="/usr/local/bin:$PATH"
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zprofile
```
Open a new terminal.

---

### `Error: listen tcp 127.0.0.1:11434: bind: address already in use`

**What it means:** Ollama is already running. This is not an error — it's fine.

**Verify:**
```bash
curl http://localhost:11434/api/tags
```
If it returns a JSON list of models, Ollama is running correctly.

---

### `ollama serve` hangs or models don't load

**Fix:** Kill any existing Ollama processes and restart:
```bash
pkill ollama 2>/dev/null; sleep 2; ollama serve
```

---

### Model download interrupted / stuck

Downloads resume automatically. Just re-run:
```bash
ollama pull qwen2.5-coder:14b
```
It picks up from where it left off.

---

### `no space left on device` during model download

Free up space first:
```bash
# See what models you have
ollama list

# Remove models you don't need
ollama rm qwen3.5:35b-a3b  # frees 23GB
ollama rm phi4-mini:latest  # frees 2.5GB
```

---

## OpenClaw Errors

### OpenClaw chat panel returns tool call JSON instead of a response

**What it means:** Working correctly — OpenClaw is an agent framework. For simple chat messages it tries to route to a skill. Use it for real tasks ("build me X", "refactor Y") not small talk.

**For plain chat:** Use Continue.dev (Cmd+L) instead.

---

### `openclaw: command not found`

**Fix:**
```bash
export PATH="$HOME/.openclaw/bin:$PATH"
echo 'export PATH="$HOME/.openclaw/bin:$PATH"' >> ~/.zprofile
```
Open a new terminal.

---

### OpenClaw "Language model unavailable" or can't connect to Ollama

**Fix — onboard OpenClaw to Ollama:**
```bash
openclaw onboard --auth-choice ollama --non-interactive --accept-risk
```

---

## Aider Errors

### `command not found: aider-offline`

The alias needs to load. Either open a new terminal, or:
```bash
source ~/.zprofile
```

---

### `aider: command not found`

```bash
pip3 install aider-chat --break-system-packages
```
Then open a new terminal.

---

### Aider can't find git repo

```bash
cd ~/my-project
git init
aider-offline
```
Aider requires a git repo to track its changes.

---


## 16GB RAM

### System slows down or fans spin when using `qwen2.5-coder:14b`

**What it means:** The 14B model uses ~9GB. Combined with macOS (~4–5GB), you're near the 16GB ceiling. Memory pressure causes swapping to disk and tanks performance.

**Fix:** Close Chrome, Slack, and any other heavy apps before starting a coding session. If you can't close them, use `qwen2.5-coder:7b` (4.7GB) for everyday work — it's somewhat slower on complex tasks but leaves enough headroom for a normal workday.

**Alternative model worth trying:** `qwen3.5:9b` (6.6GB) — a newer model that sits between 7B and 14B in both size and quality. Fits comfortably on 16GB.

---

### OpenClaw responds sluggishly or makes the machine slow all day

**What it means:** OpenClaw runs 24/7 as a boot service. If its default model is `qwen2.5-coder:14b`, that 9GB stays loaded in RAM continuously — even when you're not actively using it — leaving almost nothing for everything else.

**Fix — edit `~/.openclaw/openclaw.json`, change the primary model to a lighter one:**

Find the `agents.defaults.model.primary` field and change it to:
```
"ollama/qwen2.5:7b"
```
Or for the lightest possible footprint (recommended on 16GB):
```
"ollama/phi4-mini"
```

Then restart the OpenClaw gateway:
```bash
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

---


## General

### Everything was working, now nothing works after a restart

Ollama auto-start may have failed. Check:
```bash
brew services list | grep ollama
```
If it shows `stopped`, restart it:
```bash
brew services start ollama
```

---

### "command not found: brew"

Homebrew isn't installed or isn't in PATH.

**Install Homebrew:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Apple Silicon — add to PATH:**
```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

---

### Slow responses / model taking a long time

Normal for first response after startup (model loads into memory). Subsequent responses are much faster.

If consistently slow: you may be running a model too large for your RAM. Check which tier you're on:
```bash
sysctl -n hw.memsize | awk '{print int($1/1073741824)"GB"}'
```
Then see the hardware table in README.md to confirm you have the right model size.

---

*Hit an error not listed here? Open an issue with the full error message and output of `ollama list`.*
