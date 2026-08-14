# CONCERNS — Tech Debt, Drift, Redundancy & Security

**Analysis Date:** 2026-08-14

This document doubles as the **live-machine vs repo drift report** the user requested.
Repo root: `/Users/iemafzal/dotfiles`. Live machine: Mac Mini M4.

---

## 🔴 CRITICAL: Secrets in live `~/.zshrc`

Lines ~396–403 of live `~/.zshrc` contain plain-text API keys: `OPENROUTER_API_KEY`,
`ANTHROPIC_API_KEY`/`ANTHROPIC_AUTH_TOKEN`, `CLAUDE_CODE_MODEL`,
`GITHUB_PERSONAL_ACCESS_TOKEN`, `ADEN_API_KEY`. The repo `.zshrc` is sanitized, but:

- If the live file is ever copied into the public repo, keys leak immediately.
- Keys have been visible in this session's output → **rotate them** (OpenRouter,
  GitHub PAT, Aden).
- Fix: move to `~/.zshrc.local` (gitignored) or `~/.config/zsh/secrets.zsh`, or a
  `.env`-style loader.

---

## 📊 Live vs Repo — File-by-file drift

| Component | Repo state | Live machine state | Verdict |
|---|---|---|---|
| `~/.zshrc` | 13,790 B, dated 2025-10-29, has Amazon Q blocks, `compinit` caching, `echo "💀 Hello Engineer!"`, 7 plugins, HISTSIZE=1000, no secrets | 14,546 B, edited 2026-08, no Amazon Q, `ZSH_THEME="spaceship"` active, **20 plugins**, HISTSIZE=10000, spaceship config **inline**, Docker completions + double `compinit`, **API keys**, k3s/multipass/Antigravity | ⚠️ **Stale — big drift** |
| `~/.vimrc` | 165-line full vim config (vim-plug, coc.nvim, ale, nerdtree…) | 1 line: `set rtp+=/opt/homebrew/opt/fzf` | ⚠️ **Stale — vim abandoned** |
| `~/.vim/` | 64 MB vendored plugins | **No `~/.vim` on live machine** | ❌ **Dead weight** |
| `~/.oh-my-zsh/` | 20 MB full framework vendored; custom plugins: fzf-tab, zsh-syntax-highlighting, zsh-autosuggestions | Same custom plugins; framework updated independently (2026-04 vs 2025-10) | ⚠️ **Redundant — should install via script, not vendor** |
| `spaceship/config.zsh` | `SPACESHIP_PYTHON_SHOW=false` | `~/.config/spaceship/config.zsh` identical | ✅ **In sync** |
| `nvim/` | options.lua has `lazyredraw=true` active; custom.lua has blink.cmp block + `mason lazy=false`; lazy-lock pinned 2025 commits | options.lua has lazyredraw commented; custom.lua lacks blink.cmp block; lazy-lock has **newer** commits (Lazy update ran) | ⚠️ **Drifted 3 files — repo is a mix of older+newer than live** |
| `ghostty` config | **NOT in repo** | `~/.config/ghostty/config` — transparent theme, Hack Nerd Font Mono 20pt, bg-opacity 0.65, blur 15, "Builtin Pastel Dark" | ❌ **Missing from repo** |
| `~/.zprofile` | **NOT in repo** | Kiro pre/post, `brew shellenv`, OrbStack ref, Antigravity PATH | ❌ **Missing from repo** |
| `~/.zshenv` | **NOT in repo** | cargo env | ❌ **Missing from repo** |
| `~/.gitconfig` | **NOT in repo** | delta pager + SSH signing + identity | ❌ **Missing from repo** |
| `.gitignore` | **NOT in repo** | (none) | ❌ **Missing** |
| `setup_env.sh` | present | present | ⚠️ **Buggy (see below)** |

## 🔁 Redundancy & duplicacy inventory

1. **Spaceship config in 3 places** — same settings inline in live `.zshrc` (lines
   127–172) **and** sourced from `~/dotfiles/spaceship/config.zsh` **and**
   `~/.config/spaceship/config.zsh` (live lines 171–172). If inline and file disagree,
   last-source wins — fragile.
2. **Oh My Zsh vendored twice** — full framework in repo (20 MB) while the install
   script also curl-installs it. Framework updates can't be merged via git.
3. **`.vim/` 64 MB vendored** — vim isn't even used (no `~/.vim`, stub `.vimrc`).
4. **Double `compinit`** — OMZ runs it; Docker completions block (live line 407–411)
   runs it again. Slow startup, redundant.
5. **Plugin list duplication** — 20 plugins in live `.zshrc` vs 7 in repo; `setup_env.sh`
   clones many plugins manually (some with **invalid URLs** — `github.com/.../tree/master/...`
   are web pages, not git repos → those clones fail) that are also OMZ standard plugins.
6. **`brew install` list vs actual use** — `direnv` and `antenna` are in
   `setup_env.sh` but **not installed/used** on the live machine; conversely
   `ghostty`, `delta`, `tldr`, `thefuck`, `nvm` are used live but **not in the script**.
7. **`nvim` custom.lua** — blink.cmp block exists in repo but not live; whichever is
   canonical must be chosen.
8. **Machine-specific lines polluting shared config** — `KUBECONFIG=~/k3s.yaml`,
   `alias mp=multipass`, Antigravity/Windsurf/Docker.app PATHs, OrbStack ref → should
   not ship in a public repo as-is.

## 🐛 setup_env.sh bugs

- **Mojibake**: emoji/UTF-8 corrupted throughout (e.g. `"���🚀"`) — cosmetic but unprofessional for a public repo.
- **Invalid plugin clone URLs**: `https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/web-search` etc. are webpage URLs, not `git clone` targets → install fails silently.
- **macOS-only**: hardcoded `/opt/homebrew`, `chsh`, `$(brew --prefix)` → breaks on Linux (end goal requires macOS + Linux).
- **Not idempotent / no dry-run**; `nvim --headless +PlugInstall` runs twice (nvim and vim).
- Missing installs: `ghostty`, `delta`, `nvm`, `tldr`, `thefuck`, `lazygit`'s deps.
- `source "$HOME/.zshrc"` at end of a non-interactive bash script is a no-op/error-prone.

## ⚠️ Other issues

- **Repo has zero commits** — everything untracked; no history to fall back on.
- **`.DS_Store`** untracked in repo root (would be committed without `.gitignore`).
- Live `.zshrc` depends on `$HOME/dotfiles/...` path (line 171) — repo location baked into config; breaks if repo moved/renamed.
- `ENABLE_CORRECTION` true (repo) vs false (live); `omz update mode auto` (repo) vs `reminder` (live) — conflicting intent between copies.
- k3s/multipass indicate a local cluster workflow not represented anywhere in the repo.

## 🎯 End-goal gaps (public GitHub repo + one-command setup for macOS & Linux)

1. **Structure**: decide managed set → `.zshrc`, `.zprofile`, `.zshenv`, `.gitconfig`
   (templated), `nvim/`, `spaceship/`, `ghostty/`, `oh-my-zsh/custom/` (plugins only).
2. **Cross-platform installer**: detect `brew` (macOS) vs `apt`/`dnf`/`pacman` (Linux);
   per-OS package lists; no `/opt/homebrew` hardcoding outside macOS branch.
3. **Local-only secrets**: `~/.zshrc.local` sourced if present; never in git.
4. **`.gitignore`** for `.DS_Store`, backups, vendored installs, `*.local`.
5. **Idempotent, dry-run, error-checked script** with per-step logging.
6. Decide fate of `.vimrc`/`.vim` (recommend: delete from repo — vim abandoned).
7. Choose canonical nvim `custom.lua` + regenerate `lazy-lock.json`.
