# OpenClaw Offline Coding Setup

<p align="center">
  <strong>Free. Private. No internet. Code with AI on your own hardware — forever.</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/Internet%20Required-Setup%20Only-orange?style=for-the-badge" alt="Offline">
</p>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-offline-setup/main/install.sh)
```

---

## Why This Exists

AI coding tools have a dirty secret: they are subscription traps.

You pay $20/month for Copilot. Another $20 for Claude. Maybe $10 for ChatGPT. You become dependent on cloud APIs that can change pricing, go down mid-project, or simply be unavailable when you are on a plane, in a remote cabin, or in a country with unreliable internet. And every line of code you type gets sent to someone else's server.

The models that power these tools — Qwen, DeepSeek, Llama — are **open source**. They are free. They can run on your laptop. The only thing standing between you and a free, private, offline AI coding assistant was a few hours of painful configuration: broken PATH variables, version mismatches, mysterious errors, and documentation scattered across five different projects.

**This repo fixes that.**

One command. Thirty minutes. Then you have:

- AI chat inside VS Code — press Cmd+L and talk to your code
- Real-time autocomplete as you type — just press Tab
- A terminal agent that reads your whole project and edits files across it
- [OpenClaw](https://github.com/openclaw/openclaw) — a personal AI gateway that connects your local models to WhatsApp, iMessage, Telegram, Slack, and 20+ other messaging apps

No subscriptions. No API keys. No data leaving your machine. No internet required after setup.

**This is your AI stack. You own it.**

---

## The Hard-Won Lessons (What This Repo Pre-Fixes)

This setup was built through real-world trial and error. Every error in this table was hit, debugged, and fixed before writing the installer:

| Error You Would Have Hit | Root Cause | Pre-Fixed By |
|--------------------------|-----------|--------------|
| `command not found: ollama` | Homebrew not in PATH | Auto-patches `~/.zprofile` |
| `Language model unavailable` | Ollama not running as a service | Installs as boot daemon |
| `Unable to resolve chat model: copilot-base` | Continue's "New Experience" mode hijacks local models | Disabled in VS Code settings |
| `deepseek-r1:7b does not support tools` | Tools enabled for a model that doesn't support them | Sets `capabilities.tools: false` |
| `code: command not found` | VS Code CLI not in PATH | Detected and flagged |
| Wrong model for your RAM | Installer guessed wrong tier | RAM auto-detected, model sizes matched |
| OpenClaw returns raw JSON instead of chat | Agent mode intercepting simple messages | Explained in docs, Continue.dev used instead |
| Config invalid: Unrecognized key "maxOutput" | Stale OpenClaw config from onboarding | `openclaw doctor --fix` included in verify step |

---

## What You Get

| Tool | Role | How to Use |
|------|------|-----------|
| **Ollama** | Runs AI models locally on your hardware | Auto-starts on boot — invisible |
| **Qwen 2.5 Coder** | Your main coding brain | Press **Cmd+L** in VS Code |
| **DeepSeek R1** | Reasoning model for hard problems | Switch in Continue.dev model picker |
| **Continue.dev** | VS Code AI chat + Tab autocomplete | **Cmd+L** to chat, Tab to complete |
| **Aider** | Terminal agent — reads whole project, edits files | `aider-offline` in any project |
| **OpenClaw** | Personal AI gateway — chat via phone/messaging | `openclaw dashboard` |

---

## Hardware Requirements

| Your RAM | Chat Model | Autocomplete | Reasoning | Download Size |
|----------|-----------|--------------|-----------|---------------|
| **64GB+** | Qwen 2.5 Coder 32B | Qwen 2.5 Coder 7B | DeepSeek R1 14B | ~33GB |
| **32GB** | Qwen 2.5 Coder 32B | Qwen 2.5 Coder 7B | DeepSeek R1 7B | ~29GB |
| **16GB** | Qwen 2.5 Coder 14B | Qwen 2.5 Coder 7B | DeepSeek R1 7B | ~19GB |
| **8GB** | Qwen 2.5 Coder 7B | Qwen 2.5 Coder 3B | DeepSeek R1 1.5B | ~8GB |

**Minimum:** 8GB RAM, 40GB free disk, macOS or Linux.
**Best experience:** Apple Silicon Mac (M1–M4) with 32GB+ RAM. Unified memory architecture makes local LLMs dramatically faster than equivalent PC hardware.

---

## Installation

### The One-Liner

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-offline-setup/main/install.sh)
```

### From Clone

```bash
git clone https://github.com/YOUR_USERNAME/openclaw-offline-setup
cd openclaw-offline-setup
chmod +x install.sh
./install.sh
```

### What Happens (Automatically)

1. Detects your OS, architecture, RAM, and free disk space
2. Fixes your shell PATH — the single most common cause of broken setups
3. Installs Homebrew (macOS package manager)
4. Installs Ollama and starts it as a persistent background service
5. Downloads AI models sized for your specific hardware
6. Installs VS Code if not already present
7. Installs Continue.dev and writes a correct `~/.continue/config.json`
8. **Disables Continue's "New Experience" mode** — prevents the `copilot-base` error
9. **Sets `capabilities.tools: false` for DeepSeek** — prevents the tools support error
10. Installs OpenClaw and connects it to your local Ollama models
11. Installs Aider and sets up the `aider-offline` alias
12. Runs a full health check and reports what passed or failed

Internet is only required for this one-time setup. After that, everything is local.

---

## Daily Workflow

### VS Code Chat

Open VS Code, open any project, press **Cmd+L**:

```
> Create a REST API with JWT authentication in Express
> Add TypeScript types to all functions in this file
> Fix the error: Cannot read properties of undefined
> Refactor this component to use React hooks
> Write unit tests for the UserService class
```

Switch to DeepSeek R1 in the model picker for complex logic or algorithm problems.

### Terminal Agent

```bash
cd ~/my-project
aider-offline
```

```
> Add dark mode support across the entire app
> Migrate the database layer from raw SQL to Prisma
> Fix all TypeScript errors in the project
> Create a full test suite for the API endpoints
```

Aider reads your whole codebase, makes edits across multiple files, and auto-commits to git. Every change is reversible.

### OpenClaw Dashboard

```bash
openclaw dashboard
```

Opens a browser UI. From here you can connect messaging apps (Telegram, WhatsApp, iMessage via BlueBubbles, Discord, Slack) so your local AI responds to you wherever you are — on your phone, in any chat app, completely privately.

---

## Verify Your Setup

After installation:

```bash
bash scripts/verify.sh
```

Or manually:

```bash
# Is Ollama running?
curl -s http://localhost:11434/api/tags

# What models do you have?
ollama list

# Is the aider alias set?
grep "aider-offline" ~/.zprofile
```

---

## Useful Commands

```bash
# Restart Ollama if something seems stuck
brew services restart ollama

# Pull a new model (auto-available in Continue after restart)
ollama pull codestral:22b

# Remove a model to free disk space
ollama rm qwen3.5:35b-a3b

# Fix OpenClaw config errors
cd ~/.gemini/antigravity/scratch/openclaw && node scripts/run-node.mjs doctor --fix

# Open OpenClaw dashboard
cd ~/.gemini/antigravity/scratch/openclaw && node scripts/run-node.mjs dashboard
```

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| macOS Apple Silicon (M1–M4) | ✅ Fully tested |
| macOS Intel | ✅ Tested |
| Ubuntu 22.04+ | 🟡 Should work, less tested |
| Windows (WSL2) | 🟡 In progress |

---

## Project Structure

```
openclaw-offline-setup/
├── README.md                        ← You are here
├── QUICKSTART.md                    ← 5-minute usage guide
├── TROUBLESHOOTING.md               ← Every error + fix
├── install.sh                       ← The one-command installer
├── scripts/
│   └── verify.sh                    ← Health check script
├── configs/
│   └── continue-config-template.json ← Continue.dev config template
├── docs/
│   ├── MODELS.md                    ← Model guide and disk sizes
│   └── USAGE.md                     ← Detailed workflow guide
└── LICENSE                          ← MIT
```

---

## Built On

This project stands on the shoulders of:

- [OpenClaw](https://github.com/openclaw/openclaw) — Personal AI gateway. MIT License.
- [Ollama](https://ollama.com) — Local LLM runtime. MIT License.
- [Continue.dev](https://continue.dev) — VS Code AI assistant. Apache 2.0.
- [Aider](https://aider.chat) — Terminal coding agent. Apache 2.0.
- [Qwen 2.5 Coder](https://huggingface.co/Qwen) — Alibaba's coding model. Apache 2.0.
- [DeepSeek R1](https://huggingface.co/deepseek-ai) — DeepSeek's reasoning model. MIT License.
- [Dr. Non Arkara's offline-ai-coding](https://github.com/Nonarkara/offline-ai-coding) — Original inspiration and model selection approach.

---

## License

MIT. Use it, fork it, build on it, share it.

If this saved you hours of debugging, share it with another developer. That is the only attribution that matters.

---

*If you hit an error not covered in [TROUBLESHOOTING.md](TROUBLESHOOTING.md), open an issue. Include your OS, RAM, and the full error message.*
