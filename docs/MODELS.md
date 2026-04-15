# Model Guide

## The Three Roles

Every offline coding setup needs three models for different jobs:

### 1. Chat Model (main brain)
Used when you press Cmd+L and type a question. Handles most requests: writing code, explaining, refactoring, fixing bugs.

**Best options by RAM:**
- 32GB+: `qwen2.5-coder:32b` — near GPT-4o quality for coding
- 16GB: `qwen2.5-coder:14b` — very good, handles most tasks well
- 8GB: `qwen2.5-coder:7b` — solid for simple tasks, slower on complex ones

### 2. Autocomplete Model (Tab suggestions)
Runs silently in the background, suggests code as you type. Needs to be fast — a smaller model is better here.

**Best option (all RAM tiers):** `qwen2.5-coder:7b`
- Fast enough for real-time suggestions
- Qwen's coder-specific training makes suggestions accurate

### 3. Reasoning Model (hard problems)
Switch to this when the main model gets stuck. Better at multi-step logic, algorithm design, debugging complex issues.

**Best option:** `deepseek-r1:7b` or `deepseek-r1:14b`
- Trained specifically for chain-of-thought reasoning
- 131K context window (can read huge codebases)
- **Important:** does not support tool-calling — must set `capabilities.tools: false` in config

---

## Model Commands

```bash
# See what's installed
ollama list

# Download a model
ollama pull qwen2.5-coder:14b

# Remove a model (free disk space)
ollama rm qwen3.5:35b-a3b

# Test a model directly
ollama run qwen2.5-coder:7b "Write hello world in Python"
```

---

## Disk Space Reference

| Model | Size |
|-------|------|
| qwen2.5-coder:32b | ~19GB |
| qwen2.5-coder:14b | ~9GB |
| qwen2.5-coder:7b | ~4.7GB |
| qwen2.5-coder:3b | ~2GB |
| deepseek-r1:14b | ~9GB |
| deepseek-r1:7b | ~4.7GB |
| deepseek-r1:1.5b | ~1GB |

---

## Adding More Models Later

```bash
# Meta's general model (great for non-coding tasks)
ollama pull llama3.3:70b

# Mistral's coding model
ollama pull codestral:22b

# Microsoft's small but fast model
ollama pull phi4-mini
```

After pulling, add to `~/.continue/config.json` under `"models": [...]`.
