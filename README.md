# 🚀 iemafzal's Dotfiles

Development environment configs for **macOS (Homebrew)** and **Linux** — zsh, Spaceship
prompt, Neovim (LazyVim), Ghostty terminal, Oh My Zsh plugins and more. This repo mirrors
the live machine state: the configs here are the configs in use.

## One-command setup on a new machine

```bash
git clone https://github.com/iemafzalhassan/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup.sh
```

That's it. The script:

- Detects macOS vs Linux and installs Homebrew if missing (works on both)
- Installs all tools actually used: `git zsh neovim tmux fzf zoxide bat eza ripgrep fd jq yq lazygit lazydocker tldr thefuck delta nvm kubectl helm terraform docker` + Ghostty (macOS)
- Installs Oh My Zsh and copies the custom plugins + Spaceship theme from this repo
- **Backs up** any existing config, then symlinks everything into place
- Installs Node (nvm LTS), SDKMAN (Java 17 + Maven), and syncs Neovim plugins
- Sets zsh as default shell

### Options

```bash
bash setup.sh --minimal   # tools + configs only (skip SDKMAN/Java + nvim sync)
bash setup.sh --help
```

## What's managed here

| Repo path | Installed to | What it is |
|---|---|---|
| `.zshrc` | `~/.zshrc` | Main shell config (prompt, fzf, zoxide, nvm, aliases/functions) |
| `.zprofile` | `~/.zprofile` | Login shell (brew shellenv, Antigravity PATH) |
| `.zshenv` | `~/.zshenv` | Cargo env |
| `.gitconfig` | `~/.gitconfig` | Git: delta pager, SSH commit signing |
| `.vimrc` | `~/.vimrc` | Minimal vim compat (rtp for fzf) |
| `ghostty/config` | `~/.config/ghostty/config` | Transparent terminal theme |
| `spaceship/config.zsh` | `~/.config/spaceship/config.zsh` | Prompt overrides |
| `nvim/` | `~/.config/nvim` | Neovim (LazyVim + Dracula transparent) |
| `oh-my-zsh/custom/` | `~/.oh-my-zsh/custom/` | Plugins (fzf-tab, autosuggestions, syntax-highlighting) + Spaceship theme |

## 🔒 API keys

Real keys are **never committed**. Put them in `~/.zshrc.local` (created by the setup
script, gitignored):

```bash
export OPENROUTER_API_KEY="..."
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
export ADEN_API_KEY="..."
```

`.zshrc` automatically sources `~/.zshrc.local` if it exists.

## Re-running / updating

```bash
cd ~/dotfiles && git pull && bash setup.sh
```

Idempotent — old configs get backed up to `~/dotfiles_backup_<timestamp>/`, never deleted.
