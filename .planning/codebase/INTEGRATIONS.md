# INTEGRATIONS — External Services & Tooling

**Analysis Date:** 2026-08-14

External services / vendor integrations referenced by the configs. Split into
**live** (what the Mac Mini M4 actually runs today) and **repo-only** (stale, in the
repo but no longer live).

## Credentials in LIVE `~/.zshrc` — ⚠️ DO NOT COMMIT

The live `~/.zshrc` (lines ~396–403) contains **plain-text API keys**:

- `OPENROUTER_API_KEY` (sk-or-v1-…)
- `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` — same OpenRouter key, proxied via `ANTHROPIC_BASE_URL=http://127.0.0.1:3456/v1` (local proxy)
- `CLAUDE_CODE_MODEL=claude-3-5-sonnet-20241022`
- `GITHUB_PERSONAL_ACCESS_TOKEN` (ghp_…)
- `ADEN_API_KEY` (aden_…)

These exist **only** in the live file. The repo `.zshrc` has **no** secrets (it was
sanitized). For a **public** GitHub repo this is the #1 risk: the live file must never be
copied verbatim, and the keys shown above should be **rotated** since they have been
exposed in terminal/session output.

## Shell/IDE vendor integrations (live)

| Vendor | Where | Notes |
|---|---|---|
| Kiro CLI | `~/.zprofile` (pre/post blocks) | Shell integration, moved out of `.zshrc` |
| Antigravity IDE / CLI | live `~/.zshrc` PATH exports + `~/.zprofile` | `/Users/iemafzal/.antigravity/...`, `.antigravity-ide/...` |
| Amazon Q | repo `.zshrc` (pre/post blocks) | **Removed from live `.zshrc`** — stale in repo |
| iTerm2 | live `.zshrc` (guarded, interactive only) | `~/.iterm2_shell_integration.zsh` |
| OrbStack | `~/.zprofile` (`source ~/.orbstack/shell/init.zsh`) | Referenced but **not installed** on live machine |
| Docker Desktop | live `.zshrc` (completions fpath + `compinit`) | Also `alias ld=lazydocker` |
| Windsurf | live `.zshrc` PATH | `/Applications/Windsurf.app/...` + `~/.codeium/windsurf/bin` |

## Git identity & signing (live `~/.gitconfig` — NOT in repo)

- `user.name = iemafzalhassan`, `user.email = iemafzalhassan@gmail.com`
- **SSH signing** via `~/.ssh/id_ed25519.pub` (`gpgsign = true`, `format = ssh`, `ssh-keygen` program)
- delta pager config (side-by-side, line-numbers, decorations)
- `[safe] directory = *`

## Language/toolchain registries

- **SDKMAN** → Java 17 Temurin + Maven (`~/.sdkman`)
- **nvm** (Homebrew) → node registry, `nvm use default`
- **cargo** env via `~/.zshenv` (`. "$HOME/.cargo/env"`)
- **gcloud** CLI (GCP) + `~/.config/gcloud`
- **k3s** — `KUBECONFIG=~/k3s.yaml` (machine-local cluster; should NOT be in a public repo)

## External services referenced by configs (no credentials)

- **fzf** (`FZF_BASE=/opt/homebrew/opt/fzf`) — brew integration
- **Homebrew** — `HOMEBREW_NO_ENV_HINTS=1`, shellenv in `~/.zprofile`
- **neofetch** (`alias sysinfo`) — `~/.config/neofetch`
- **raycast, btop, gh, github-copilot, goose, opencode, 1mcp, mcp-servers** — live `~/.config/` dirs, **not** part of this repo's managed set

## Databases / webhooks / auth providers

None — this is a local shell config, no server-side integrations.
