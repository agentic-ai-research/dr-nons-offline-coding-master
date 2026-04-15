#!/usr/bin/env bash
# =============================================================================
# OPENCLAW OFFLINE CODING SETUP
# Sets up a complete offline AI coding environment:
#   - Ollama (local LLM runtime)
#   - AI models sized for your hardware
#   - OpenClaw (personal AI gateway)
#   - VS Code + Continue.dev (inline AI chat + autocomplete)
#   - Aider (terminal coding agent)
#
# Usage:
#   bash install.sh
#   or
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/openclaw-offline-setup/main/install.sh | bash
# =============================================================================

set -euo pipefail

# =============================================================================
# COLORS
# =============================================================================
BOLD='\033[1m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

ok()   { echo -e "${GREEN}✓${RESET} $1"; }
info() { echo -e "${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET} $1"; }
err()  { echo -e "${RED}✗${RESET} $1"; }
header() {
  echo ""
  echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}  $1${RESET}"
  echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

# =============================================================================
# STEP 0: DETECT SYSTEM
# =============================================================================
header "DETECTING YOUR SYSTEM"

# OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  SHELL_RC="$HOME/.zprofile"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  SHELL_RC="$HOME/.bashrc"
else
  err "Unsupported OS: $OSTYPE"
  echo "Supported: macOS, Linux"
  exit 1
fi
ok "OS: $OS"

# Architecture
ARCH=$(uname -m)
case "$ARCH" in
  arm64|aarch64) ARCH_FRIENDLY="Apple Silicon / ARM64" ;;
  x86_64)        ARCH_FRIENDLY="Intel x86_64" ;;
  *) err "Unsupported architecture: $ARCH"; exit 1 ;;
esac
ok "Architecture: $ARCH_FRIENDLY"

# RAM
if [[ "$OS" == "macos" ]]; then
  RAM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
else
  RAM_BYTES=$(($(grep MemTotal /proc/meminfo | awk '{print $2}') * 1024))
fi
RAM_GB=$((RAM_BYTES / 1073741824))
ok "RAM: ${RAM_GB}GB"

# Disk
if [[ "$OS" == "macos" ]]; then
  FREE_GB=$(df -g "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || echo "0")
else
  FREE_GB=$(df -BG "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G' || echo "0")
fi
ok "Free disk: ${FREE_GB}GB"
[ "$FREE_GB" -lt 40 ] && warn "Low disk space (${FREE_GB}GB free). Models need ~25GB."

# =============================================================================
# STEP 1: CHOOSE MODELS BASED ON RAM
# =============================================================================
header "SELECTING MODELS FOR YOUR HARDWARE"

if [ "$RAM_GB" -ge 64 ]; then
  CHAT_MODEL="qwen2.5-coder:32b"
  AUTOCOMPLETE_MODEL="qwen2.5-coder:7b"
  REASONING_MODEL="deepseek-r1:14b"
  info "64GB+ → 32B chat + 7B autocomplete + 14B reasoning"
elif [ "$RAM_GB" -ge 32 ]; then
  CHAT_MODEL="qwen2.5-coder:32b"
  AUTOCOMPLETE_MODEL="qwen2.5-coder:7b"
  REASONING_MODEL="deepseek-r1:7b"
  info "32GB → 32B chat + 7B autocomplete + 7B reasoning"
elif [ "$RAM_GB" -ge 16 ]; then
  CHAT_MODEL="qwen2.5-coder:14b"
  AUTOCOMPLETE_MODEL="qwen2.5-coder:7b"
  REASONING_MODEL="deepseek-r1:7b"
  info "16GB → 14B chat + 7B autocomplete + 7B reasoning"
elif [ "$RAM_GB" -ge 8 ]; then
  CHAT_MODEL="qwen2.5-coder:7b"
  AUTOCOMPLETE_MODEL="qwen2.5-coder:3b"
  REASONING_MODEL="deepseek-r1:1.5b"
  warn "8GB → 7B chat + 3B autocomplete (slower but works)"
else
  err "Minimum 8GB RAM required. You have ${RAM_GB}GB."
  exit 1
fi

# =============================================================================
# STEP 2: FIX SHELL PATH
# =============================================================================
header "FIXING SHELL PATH"

if [[ "$OS" == "macos" && "$ARCH" == "arm64" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$OS" == "macos" ]]; then
  HOMEBREW_PREFIX="/usr/local"
else
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

if ! grep -q "$HOMEBREW_PREFIX/bin" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# OpenClaw offline coding setup" >> "$SHELL_RC"
  echo "export PATH=\"$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:\$PATH\"" >> "$SHELL_RC"
  ok "PATH updated in $SHELL_RC"
else
  ok "PATH already configured"
fi

export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# =============================================================================
# STEP 3: HOMEBREW
# =============================================================================
header "STEP 1/6 — HOMEBREW"

if command -v brew &>/dev/null; then
  ok "Homebrew already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
  ok "Homebrew installed"
fi

# =============================================================================
# STEP 4: OLLAMA
# =============================================================================
header "STEP 2/6 — OLLAMA"

if command -v ollama &>/dev/null; then
  ok "Ollama already installed"
  brew upgrade ollama 2>/dev/null || true
else
  info "Installing Ollama..."
  brew install ollama
  ok "Ollama installed"
fi

# Start Ollama service
if [[ "$OS" == "macos" ]]; then
  brew services start ollama 2>/dev/null || true
else
  ollama serve &>/dev/null &
fi

# Wait for Ollama to be ready
info "Waiting for Ollama to start..."
for i in {1..15}; do
  if curl -s http://localhost:11434/api/tags &>/dev/null; then
    ok "Ollama is running"
    break
  fi
  sleep 2
  if [ "$i" -eq 15 ]; then
    warn "Ollama slow to start. Continuing anyway — models will download when it's ready."
  fi
done

# =============================================================================
# STEP 5: DOWNLOAD MODELS
# =============================================================================
header "STEP 3/6 — DOWNLOADING AI MODELS"

warn "This downloads 15–30GB. Get a coffee. You only do this once."
echo ""

pull_model() {
  local model=$1
  local label=$2
  if ollama list 2>/dev/null | grep -q "^${model}"; then
    ok "$label already downloaded"
    return 0
  fi
  info "Downloading $label ($model)..."
  local attempt=1
  while [ $attempt -le 3 ]; do
    if ollama pull "$model"; then
      ok "$label downloaded"
      return 0
    fi
    attempt=$((attempt + 1))
    warn "Retry $attempt/3..."
    sleep 5
  done
  err "Failed to download $model after 3 attempts"
  return 1
}

pull_model "$CHAT_MODEL"        "Qwen Coder (chat)"
pull_model "$AUTOCOMPLETE_MODEL" "Qwen Coder (autocomplete)"
pull_model "$REASONING_MODEL"   "DeepSeek R1 (reasoning)"

# =============================================================================
# STEP 6: VS CODE
# =============================================================================
header "STEP 4/6 — VS CODE"

if command -v code &>/dev/null || [ -d "/Applications/Visual Studio Code.app" ]; then
  ok "VS Code already installed"
else
  info "Installing VS Code..."
  brew install --cask visual-studio-code
  ok "VS Code installed"
fi

# Install shell command if missing
if ! command -v code &>/dev/null; then
  info "Installing 'code' shell command..."
  cat << 'EOF'
  ⚠ Run this manually in VS Code:
     Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"
  Then reopen your terminal.
EOF
fi

# =============================================================================
# STEP 7: CONTINUE.DEV
# =============================================================================
header "STEP 5/6 — CONTINUE.DEV (VS CODE AI CHAT)"

# Install extension
if command -v code &>/dev/null; then
  code --install-extension Continue.continue 2>/dev/null && ok "Continue.dev installed" || warn "Could not auto-install Continue.dev — install manually from VS Code Extensions (Cmd+Shift+X)"
fi

# Write Continue config
mkdir -p ~/.continue
cat > ~/.continue/config.json << CONTINUEEOF
{
  "models": [
    {
      "title": "Qwen Coder (Chat)",
      "provider": "ollama",
      "model": "$CHAT_MODEL",
      "apiBase": "http://localhost:11434",
      "contextLength": 32768,
      "completionOptions": { "temperature": 0.1, "maxTokens": 4096 },
      "capabilities": { "tools": false }
    },
    {
      "title": "DeepSeek R1 (Reasoning)",
      "provider": "ollama",
      "model": "$REASONING_MODEL",
      "apiBase": "http://localhost:11434",
      "contextLength": 131072,
      "completionOptions": { "temperature": 0.1, "maxTokens": 4096 },
      "capabilities": { "tools": false }
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen Coder (Autocomplete)",
    "provider": "ollama",
    "model": "$AUTOCOMPLETE_MODEL",
    "apiBase": "http://localhost:11434"
  },
  "allowAnonymousTelemetry": false
}
CONTINUEEOF
ok "Continue.dev configured"

# Fix Continue NE mode (causes 'copilot-base' error)
VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"

if [[ "$OS" == "linux" ]]; then
  VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
  VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"
fi

mkdir -p "$VSCODE_SETTINGS_DIR"

if [ -f "$VSCODE_SETTINGS_FILE" ]; then
  # Add settings if not already present
  if ! grep -q "enableNewExperience" "$VSCODE_SETTINGS_FILE"; then
    # Insert before closing brace
    python3 - "$VSCODE_SETTINGS_FILE" << 'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
data["continue.enableNewExperience"] = False
data["continue.showInlineTip"] = False
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
print("VS Code settings updated")
PYEOF
    ok "Disabled Continue NE mode in VS Code settings"
  else
    ok "Continue NE mode already configured"
  fi
else
  echo '{"continue.enableNewExperience": false, "continue.showInlineTip": false}' > "$VSCODE_SETTINGS_FILE"
  ok "VS Code settings created with Continue NE disabled"
fi

# =============================================================================
# STEP 8: OPENCLAW
# =============================================================================
header "STEP 6/6 — OPENCLAW (PERSONAL AI GATEWAY)"

if command -v openclaw &>/dev/null || command -v npx &>/dev/null; then
  if ! command -v openclaw &>/dev/null; then
    info "Installing OpenClaw..."
    npm install -g openclaw@latest 2>/dev/null || \
    curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
  else
    ok "OpenClaw already installed"
  fi

  info "Connecting OpenClaw to your local Ollama models..."
  openclaw onboard \
    --auth-choice ollama \
    --non-interactive \
    --accept-risk \
    --install-daemon 2>/dev/null && ok "OpenClaw connected to Ollama" \
    || warn "OpenClaw onboard needs manual step — run: openclaw onboard"
else
  info "Installing OpenClaw..."
  curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
  export PATH="$HOME/.openclaw/bin:$PATH"
  echo "export PATH=\"\$HOME/.openclaw/bin:\$PATH\"" >> "$SHELL_RC"
  openclaw onboard \
    --auth-choice ollama \
    --non-interactive \
    --accept-risk \
    --install-daemon 2>/dev/null && ok "OpenClaw connected to Ollama" \
    || warn "OpenClaw onboard needs manual step — run: openclaw onboard"
fi

# =============================================================================
# STEP 9: AIDER (TERMINAL AGENT)
# =============================================================================
header "INSTALLING AIDER (TERMINAL CODING AGENT)"

if command -v aider &>/dev/null; then
  ok "Aider already installed"
else
  info "Installing Aider..."
  pip3 install aider-chat --break-system-packages 2>/dev/null || \
  pip3 install aider-chat --user 2>/dev/null || \
  brew install aider 2>/dev/null || \
  warn "Could not install Aider. Install manually: pip3 install aider-chat"
fi

if ! grep -q "aider-offline" "$SHELL_RC" 2>/dev/null; then
  echo "alias aider-offline='aider --model ollama_chat/$CHAT_MODEL'" >> "$SHELL_RC"
  ok "Added 'aider-offline' alias"
else
  ok "'aider-offline' alias already set"
fi

# Export alias for current session
alias aider-offline="aider --model ollama_chat/$CHAT_MODEL"

# =============================================================================
# VERIFY
# =============================================================================
header "VERIFYING INSTALLATION"

PASS=0
FAIL=0

check() {
  if eval "$2" &>/dev/null; then
    ok "$1"
    PASS=$((PASS + 1))
  else
    err "$1 — $3"
    FAIL=$((FAIL + 1))
  fi
}

check "Ollama running"         "curl -s http://localhost:11434/api/tags"        "Run: ollama serve"
check "Chat model available"   "ollama list | grep -q '$CHAT_MODEL'"            "Run: ollama pull $CHAT_MODEL"
check "Autocomplete model"     "ollama list | grep -q '${AUTOCOMPLETE_MODEL%%:*}'" "Run: ollama pull $AUTOCOMPLETE_MODEL"
check "DeepSeek model"         "ollama list | grep -q '${REASONING_MODEL%%:*}'" "Run: ollama pull $REASONING_MODEL"
check "Continue config exists" "[ -f ~/.continue/config.json ]"                 "Re-run this script"

echo ""
echo -e "${BOLD}Verification: ${PASS} passed, ${FAIL} failed${RESET}"

# =============================================================================
# DONE
# =============================================================================
header "🎉 SETUP COMPLETE"

cat << EOF
You now have a complete offline AI coding stack:

  ✓ Ollama         — local AI engine (auto-starts on boot)
  ✓ Models         — $CHAT_MODEL (chat)
  ✓ Models         — $AUTOCOMPLETE_MODEL (autocomplete)
  ✓ Models         — $REASONING_MODEL (reasoning)
  ✓ Continue.dev   — VS Code AI chat (press Cmd+L)
  ✓ Aider          — terminal agent (run: aider-offline)
  ✓ OpenClaw       — personal AI gateway (run: openclaw dashboard)

Next steps:
  1. Open a NEW terminal (loads updated PATH + aliases)
  2. Open VS Code → press Cmd+L → chat with AI
  3. cd into any project → run: aider-offline

No internet required. Your code stays on your machine.
EOF
