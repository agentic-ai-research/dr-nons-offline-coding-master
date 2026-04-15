# Quick Start — Offline AI Coding in 5 Minutes

Assumes you've already run `install.sh`. If not, go to [README.md](README.md) first.

---

## Your 3 Tools

| Press / Run | What Opens | Best For |
|------------|-----------|----------|
| **Cmd+L** in VS Code | Continue.dev AI chat | Everyday coding help |
| `aider-offline` in terminal | Aider agent | Multi-file changes |
| `openclaw dashboard` | OpenClaw browser UI | Chat via phone/messaging apps |

---

## First 5 Minutes

**1. Open VS Code**
```
Cmd+Space → "Visual Studio Code" → Enter
```

**2. Open a project**
```
File → Open Folder → pick any folder
```

**3. Press Cmd+L and try:**
```
Create a Python function that reads a JSON file and returns all keys
```

**4. Accept the code → press Tab for autocomplete as you type**

That's it. You're coding with AI, offline, for free.

---

## Common Prompts That Work Great

**Start a new project:**
```
Create a Next.js app with TypeScript and Tailwind CSS
```

**Add to existing code:**
```
Add error handling to all async functions in this file
```

**Debugging:**
```
Fix the error: TypeError: Cannot read property 'map' of undefined
```

**Refactoring:**
```
Refactor this to use React hooks instead of class components
```

**Documentation:**
```
Add JSDoc comments to all exported functions
```

**Switch to DeepSeek for hard problems:**
In Continue.dev, click the model name at the bottom of the chat → switch to "DeepSeek R1 (Reasoning)" for complex logic, algorithms, or tricky bugs.

---

## Terminal Agent (Aider)

Use this when you want AI to read your whole project and make changes across multiple files:

```bash
cd ~/my-project
aider-offline
```

Example session:
```
> Add authentication to all API endpoints
> Create a test file for the user service
> Refactor the database queries to use transactions
> Fix all ESLint errors
```

Each response auto-commits to git so you can undo anything.

---

## Verify It's All Working

```bash
# Ollama running?
curl -s http://localhost:11434/api/tags | python3 -m json.tool | grep name

# Models available?
ollama list

# OpenClaw status?
openclaw gateway status
```

---

## Going Offline

After setup, disconnect WiFi and try Cmd+L. It works. Everything is local.

To push work when back online:
```bash
git add -A && git commit -m "built offline" && git push
```

---

*Full usage guide: [docs/USAGE.md](docs/USAGE.md) | Problems: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)*
