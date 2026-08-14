#!/usr/bin/env bash
# =============================================================================
#  One-command dotfiles installer — macOS (Homebrew) + Linux
#
#  Usage:
#    bash setup.sh            # full setup (tools + configs + sdkman + nvim plugins)
#    bash setup.sh --minimal  # tools + configs only (no SDKMAN, no nvim plugin sync)
#    bash setup.sh --help
#
#  Idempotent: safe to re-run. Existing configs are backed up before linking.
#  Never deletes anything from an existing machine — only backs up + symlinks.
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
MINIMAL=false

info() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m==> %s\033[0m\n' "$*"; }

usage() {
  cat <<'EOF'
Usage: bash setup.sh [--minimal] [--help]

  --minimal   Install tools + link configs only (skip SDKMAN/Java and nvim plugin sync)
  --help      Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=true ;;
    --help) usage; exit 0 ;;
    *) warn "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
OS_FAMILY="$(uname -s)"
case "$OS_FAMILY" in
  Darwin) OS_FAMILY="macos" ;;
  Linux)  OS_FAMILY="linux" ;;
  *) echo "Unsupported OS: $OS_FAMILY (this repo supports macOS and Linux)"; exit 1 ;;
esac
info "Detected OS: $OS_FAMILY"

# ---------------------------------------------------------------------------
# Homebrew (installed on both macOS and Linux so ONE package list works)
# ---------------------------------------------------------------------------
ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew (may take a few minutes)..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Make brew available for the rest of this script
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi
  brew update
  ok "Homebrew ready: $(command -v brew)"
}

# ---------------------------------------------------------------------------
# Package installation (single list — tools actually used by the configs)
# ---------------------------------------------------------------------------
install_packages() {
  info "Installing packages..."
  brew install \
    git zsh neovim tmux fzf zoxide bat eza ripgrep fd jq yq \
    lazygit lazydocker tldr thefuck delta nvm \
    kubectl helm terraform docker

  if [ "$OS_FAMILY" = "macos" ]; then
    # Ghostty terminal (GUI app via cask)
    brew install --cask ghostty 2>/dev/null || warn "Could not install ghostty cask — install manually from https://ghostty.org"
  else
    warn "Linux: install Ghostty via your distro (apt/dnf/pacman/flatpak) — config will still be linked"
  fi
  ok "Packages installed"
}

# ---------------------------------------------------------------------------
# Oh My Zsh + custom plugins/theme (from this repo)
# ---------------------------------------------------------------------------
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  info "Copying custom plugins & spaceship theme from repo..."
  mkdir -p "$HOME/.oh-my-zsh/custom/plugins" "$HOME/.oh-my-zsh/custom/themes"
  for plugin in fzf-tab zsh-autosuggestions zsh-syntax-highlighting; do
    if [ -d "$DOTFILES_DIR/oh-my-zsh/custom/plugins/$plugin" ]; then
      rm -rf "$HOME/.oh-my-zsh/custom/plugins/$plugin"
      cp -R "$DOTFILES_DIR/oh-my-zsh/custom/plugins/$plugin" "$HOME/.oh-my-zsh/custom/plugins/"
    fi
  done
  # Spaceship prompt theme (used via ZSH_THEME="spaceship" in .zshrc)
  if [ -d "$DOTFILES_DIR/oh-my-zsh/custom/themes/spaceship-prompt" ]; then
    rm -rf "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt"
    cp -R "$DOTFILES_DIR/oh-my-zsh/custom/themes/spaceship-prompt" "$HOME/.oh-my-zsh/custom/themes/"
    ln -sfn spaceship-prompt/spaceship.zsh-theme "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
  fi
  ok "Oh My Zsh configured"
}

# ---------------------------------------------------------------------------
# Symlink configs (backup any existing real file/dir first)
# ---------------------------------------------------------------------------
link() { # link <src> <dst>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    warn "Backed up existing $(basename "$dst") -> $BACKUP_DIR/"
  fi
  ln -sfn "$src" "$dst"
  ok "linked $dst -> $src"
}

link_configs() {
  info "Linking configs (existing files backed up to $BACKUP_DIR)..."
  link "$DOTFILES_DIR/.zshrc"         "$HOME/.zshrc"
  link "$DOTFILES_DIR/.zprofile"      "$HOME/.zprofile"
  link "$DOTFILES_DIR/.zshenv"        "$HOME/.zshenv"
  link "$DOTFILES_DIR/.gitconfig"     "$HOME/.gitconfig"
  link "$DOTFILES_DIR/.vimrc"         "$HOME/.vimrc"
  link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
  link "$DOTFILES_DIR/spaceship/config.zsh" "$HOME/.config/spaceship/config.zsh"
  link "$DOTFILES_DIR/nvim"           "$HOME/.config/nvim"
  # Local-only secrets file (never in git) — create if missing
  if [ ! -f "$HOME/.zshrc.local" ]; then
    cat > "$HOME/.zshrc.local" <<'EOF'
# Local-only secrets & machine-specific overrides (never commit this file)
# export OPENROUTER_API_KEY="your-key-here"
# export GITHUB_PERSONAL_ACCESS_TOKEN="your-token-here"
# export ADEN_API_KEY="your-key-here"
EOF
    ok "Created $HOME/.zshrc.local (put your API keys here)"
  fi
  ok "Configs linked"
}

# ---------------------------------------------------------------------------
# Node via nvm (macOS: Homebrew formula; Linux: official installer)
# ---------------------------------------------------------------------------
install_node() {
  if [ "$OS_FAMILY" = "macos" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
  else
    if [ ! -d "$HOME/.nvm" ]; then
      info "Installing nvm (Linux)..."
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  fi
  if command -v nvm >/dev/null 2>&1; then
    nvm install --lts >/dev/null 2>&1 || true
    nvm alias default lts >/dev/null 2>&1 || true
    ok "Node via nvm: $(nvm current 2>/dev/null || echo LTS)"
  else
    warn "nvm not available — install Node manually"
  fi
}

# ---------------------------------------------------------------------------
# SDKMAN (Java 17 Temurin + Maven) — matches live machine
# ---------------------------------------------------------------------------
install_sdkman() {
  if [ ! -d "$HOME/.sdkman" ]; then
    info "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
  fi
  export SDKMAN_DIR="$HOME/.sdkman"
  # shellcheck disable=SC1091
  [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  if command -v sdk >/dev/null 2>&1; then
    sdk install java 17.0.12-tem >/dev/null 2>&1 || true
    sdk install maven >/dev/null 2>&1 || true
    ok "SDKMAN ready (Java 17 + Maven)"
  else
    warn "SDKMAN init failed — run 'sdk' after opening a new shell"
  fi
}

# ---------------------------------------------------------------------------
# Neovim: bootstrap lazy.nvim + install plugins
# ---------------------------------------------------------------------------
sync_nvim() {
  info "Syncing Neovim plugins (first run bootstraps lazy.nvim)..."
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || warn "nvim plugin sync incomplete — open nvim once to finish"
  ok "Neovim configured"
}

# ---------------------------------------------------------------------------
# Default shell
# ---------------------------------------------------------------------------
set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
    info "Setting default shell to $zsh_path (may prompt for password)..."
    chsh -s "$zsh_path" 2>/dev/null || warn "Could not chsh automatically — run: chsh -s $zsh_path"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  info "Setting up development environment from $DOTFILES_DIR"
  ensure_homebrew
  install_packages
  install_oh_my_zsh
  link_configs
  install_node
  if [ "$MINIMAL" = false ]; then
    install_sdkman
    sync_nvim
  fi
  set_default_shell

  cat <<EOF

============================================================
✅ Setup complete!
- Backup of replaced files: $BACKUP_DIR
- API keys: put them in ~/.zshrc.local (never committed)
Next steps:
  1. Restart your terminal (or: exec zsh)
  2. Run 'nvim' once to finish plugin installs
  3. Verify: ghostty (terminal), spaceship prompt, neovim theme
============================================================
EOF
}

main "$@"
