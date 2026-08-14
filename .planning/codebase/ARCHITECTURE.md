# ARCHITECTURE — Layout, Flow & Patterns

**Analysis Date:** 2026-08-14

## Pattern

This is a **config-as-files + bootstrap-script** repo, not a program. The mental model:

```
~/dotfiles (repo)
   │  config files mirror $HOME paths
   ▼
setup_env.sh ──► backup existing → brew installs → oh-my-zsh + plugins
                  → vim-plug → symlink files into $HOME → sdkman → git/fzf config
   ▼
$HOME/.zshrc ──► oh-my-zsh → spaceship prompt → fzf/zoxide/nvm/sdkman → aliases/functions
$HOME/.config/nvim ──► init.lua → lazy.nvim → LazyVim → custom plugins (dracula, blink.cmp…)
$HOME/.config/ghostty (live only) ──► transparent terminal theme
```

## Deployment model (current, broken)

`setup_env.sh` uses **symlinks**: `ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"`, etc.
**However, on the live Mac Mini M4 the files are NOT symlinks** — `~/.zshrc`,
`~/.config/nvim`, `~/.config/spaceship`, `~/.oh-my-zsh` are all **real files/dirs**
copied independently. The repo and the live machine have **drifted apart** (repo files
mostly dated 2025-10-29; live files edited through 2026-08). So the repo is currently a
**stale snapshot**, not the source of truth.

## Bootstrap flow (setup_env.sh)

1. Backup existing `$HOME` configs to `~/dotfiles_backup_<timestamp>/`
2. Install Homebrew (if missing) + `brew update`
3. `brew install` ~20 packages (git zsh neovim tmux fzf zoxide direnv bat eza rg fd jq yq kubectl helm terraform docker lazygit lazydocker golang node python sdkman-cli spaceship-prompt antenna)
4. Install Oh My Zsh (unattended) + clone custom plugins into `${ZSH_CUSTOM}/plugins/`
5. Install vim-plug for nvim; link dotfiles into `$HOME`
6. `nvim --headless +PlugInstall` (x2 — nvim then vim)
7. Install SDKMAN (Java 17 + Maven)
8. Global git config (editor=nvim, pull.rebase=false, defaultBranch=main, fetch.prune, push.autoSetupRemote)
9. fzf install, `chsh -s zsh`, source `~/.zshrc`

## Shell init chain (live)

- `~/.zshenv` → cargo env
- `~/.zprofile` → Kiro pre/post, `brew shellenv`, OrbStack (stale ref), Antigravity PATH
- `~/.zshrc` → PATH array → OMZ (`source $ZSH/oh-my-zsh.sh`) → spaceship → history → fzf/zoxide/nvm/sdkman aliases/functions → **API keys** → Docker completions (`compinit` again)

## Neovim init chain

```
nvim/init.lua
  └─ require("config.lazy")
       └─ lazy.nvim bootstrap (clones lazy.nvim if missing)
            └─ spec: LazyVim/LazyVim (import lazyvim.plugins) + { import = "plugins" }
                 └─ lua/plugins/custom.lua  → dracula (transparent), blink.cmp, mason, lspconfig, treesitter
                 └─ lua/plugins/example.lua → disabled template (stylua: ignore, returns {})
```

Keymaps/autocmds/options load via LazyVim's `VeryLazy` events
(`lua/config/keymaps.lua`, `autocmds.lua`, `options.lua`).

## Abstractions & entry points

| Entry point | Responsibility |
|---|---|
| `setup_env.sh` | One-shot provisioning (macOS/brew only) |
| `.zshrc` | Interactive shell experience (prompt, tools, aliases) |
| `nvim/init.lua` | Editor bootstrap |
| `spaceship/config.zsh` | Prompt section overrides (repo; also duplicated inline in `.zshrc`) |

## Known architectural smells

- **Config drift**: repo ≠ live for every major file (`.zshrc`, `nvim/*`, `oh-my-zsh`).
- **Split-brain spaceship config**: same settings inline in `.zshrc` AND sourced from
  `~/.config/spaceship/config.zsh` AND `~/dotfiles/spaceship/config.zsh` (live line 171–172).
- **Vendored bloat**: `.oh-my-zsh/` (20 MB) + `.vim/` (64 MB) committed wholesale even
  though oh-my-zsh is brew/curl-installed and vim is effectively unused.
- **Hardcoded macOS/brew paths** everywhere — not Linux-portable as-is.
- **Machine-specific leaks**: k3s KUBECONFIG, multipass, Antigravity, Windsurf,
  Docker.app paths in live `.zshrc` — wrong content for a public repo.
