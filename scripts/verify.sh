#!/usr/bin/env bash
# Run this anytime to check your offline coding setup is healthy

BOLD='\033[1m'
RESET='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'

ok()   { echo -e "${GREEN}✓${RESET} $1"; }
err()  { echo -e "${RED}✗${RESET} $1 → $2"; }
warn() { echo -e "${YELLOW}⚠${RESET} $1"; }

echo ""
echo -e "${BOLD}OpenClaw Offline Setup — Health Check${RESET}"
echo "──────────────────────────────────────"
echo ""

PASS=0
FAIL=0

check() {
  local label="$1"
  local cmd="$2"
  local fix="$3"
  if eval "$cmd" &>/dev/null; then
    ok "$label"
    PASS=$((PASS + 1))
  else
    err "$label" "$fix"
    FAIL=$((FAIL + 1))
  fi
}

check "Ollama installed"         "command -v ollama"                               "brew install ollama"
check "Ollama running"           "curl -s http://localhost:11434/api/tags"          "brew services start ollama"
check "Qwen Coder model"         "ollama list | grep -q 'qwen2.5-coder'"           "ollama pull qwen2.5-coder:14b"
check "DeepSeek model"           "ollama list | grep -q 'deepseek-r1'"             "ollama pull deepseek-r1:7b"
check "Continue config"          "[ -f ~/.continue/config.json ]"                   "Re-run install.sh"
check "Continue uses Ollama"     "grep -q 'ollama' ~/.continue/config.json"         "Re-run install.sh"
check "DeepSeek tools disabled"  "python3 -c \"import json; d=json.load(open(os.path.expanduser('~/.continue/config.json'))); models=[m for m in d.get('models',[]) if 'deepseek' in m.get('model','')]; exit(0 if all(m.get('capabilities',{}).get('tools')==False for m in models) else 1)\" 2>/dev/null || grep -A2 'deepseek' ~/.continue/config.json | grep -q 'tools.*false'" "Add capabilities.tools:false to DeepSeek in ~/.continue/config.json"
check "Ollama auto-start"        "brew services list | grep ollama | grep -q started" "brew services start ollama"
check "OpenClaw installed"       "command -v openclaw"                             "curl -fsSL https://openclaw.ai/install.sh | bash"
check "Aider installed"          "command -v aider"                                "pip3 install aider-chat --break-system-packages"

echo ""
echo "──────────────────────────────────────"
echo -e "${BOLD}Result: ${PASS} passed, ${FAIL} failed${RESET}"

if [ "$FAIL" -eq 0 ]; then
  echo ""
  echo -e "${GREEN}${BOLD}All checks passed. Your offline coding stack is healthy.${RESET}"
  echo ""
  echo "Open VS Code → press Cmd+L → start coding"
else
  echo ""
  warn "Fix the items marked ✗ above, then re-run this script."
fi
echo ""
