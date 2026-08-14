# STACK — Dotfiles Repository

**Analysis Date:** 2026-08-14

## What this repo is

A personal **dotfiles / environment provisioning** repository for `iemafzal`'s development
machine (Mac Mini M4, macOS). It is **not** an application codebase — it is a set of
shell/editor/terminal configs plus one bootstrap script (`setup_env.sh`) that installs
tools and symlinks configs into `$HOME`.

Repo root: `/Users/iemafzal/dotfiles` (no commits yet — everything untracked).

## Languages / runtimes used in configs

| Language | Where | Purpose |
|---|---|---|
| zsh | `.zshrc` | Main shell config (~420 lines live, ~400 in repo) |
| Lua | `nvim/lua/**` | Neovim config (LazyVim) |
| Vimscript | `.vimrc` | **Stale** legacy Vim config (165 lines; live `~/.vimrc` is a 1-line stub) |
| Bash | `setup_env.sh` | Provisioning/install script |
| TOML-ish key-value | `~/.config/ghostty/config` (live only) | Ghostty terminal config (not in repo) |

## Shell & prompt stack

- **zsh** — default shell (macOS + Homebrew)
- **Oh My Zsh** — framework; repo vendors the full install (`.oh-my-zsh/`, ~20 MB)
- **Spaceship prompt** — installed via Homebrew (`/opt/homebrew/opt/spaceship/spaceship.zsh`); custom section order/colors
- **zsh plugins** (live): `docker kubectl terraform gcloud history-substring-search zsh-syntax-highlighting zsh-autosuggestions web-search gh aliases kubectx docker-compose helm httpie procs systemadmin brew tldr task taskwarrior tmux thefuck`
- Custom OMZ plugins vendored in `.oh-my-zsh/custom/plugins/`: `fzf-tab`, `zsh-syntax-highlighting`, `zsh-autosuggestions`

## CLI tools referenced

| Tool | Used for | In repo script? |
|---|---|---|
| Homebrew / brew | package manager (macOS) | yes |
| fzf | fuzzy finder (files, cd, env, tmux) | yes |
| zoxide | smart `cd` (`z`) | yes |
| bat | `cat` replacement, fzf previews | yes |
| eza | `ls` replacement (icons, git) | yes |
| ripgrep (`rg`) | fzf default command, `rgf` alias | yes |
| fd | file finder | yes |
| jq / yq | JSON/YAML parsing | yes |
| delta | git pager (`GIT_PAGER`, `~/.gitconfig`) | no (not in setup list) |
| lazygit / lazydocker | TUI git/docker | yes |
| tmux | sessions (`ftmux`) | yes |
| tldr | `man` replacement | yes |
| thefuck | command correction | yes |
| direnv | env loading | **in setup script but NOT installed on live machine** |
| neovim | main editor (`vi`/`vim` aliased to it) | yes |
| ghostty | terminal emulator | **NOT in setup script; config missing from repo** |

## Dev toolchains

- **nvm** (Homebrew) → node (default version auto-activated in live `.zshrc`)
- **Go** (brew), **Python3** (brew + `~/.neovim-python` venv for nvim provider)
- **SDKMAN** → Java 17 (Temurin) + Maven; lazy-loaded `sdk()` function
- **Ruby** compile flags (`CPPFLAGS`), cargo env via `~/.zshenv`

## Ops / cloud tooling

- kubectl, helm, terraform, docker, gcloud (CLI)
- `KUBECONFIG=~/k3s.yaml` + `alias mp=multipass` (live `.zshrc` — machine-specific, k3s cluster)

## Editor stack (Neovim / LazyVim)

- `nvim/init.lua` → `require("config.lazy")` → lazy.nvim bootstrap
- LazyVim distribution + ~30 pinned plugins (`nvim/lazy-lock.json`)
- Custom: **Dracula theme with transparency** (`lua/plugins/custom.lua`), blink.cmp, mason, nvim-lspconfig (lua_ls), nvim-treesitter
- Disabled: catppuccin, tokyonight
- `lua/config/`: `lazy.lua`, `options.lua`, `keymaps.lua`, `autocmds.lua`
- `lua/plugins/`: `custom.lua`, `example.lua` (disabled template)

## OS / hardware specificity

- **macOS-only paths** baked in: `/opt/homebrew/...` (Apple Silicon), `/Applications/Docker.app/...`, `/Applications/Windsurf.app/...`, `/Applications/Antigravity.app/...`, iTerm2 integration, Amazon Q/Kiro shell blocks
- Homebrew is the assumed package manager everywhere (`setup_env.sh`, `.zshrc` NVM block, fzf bindings, spaceship source path)
