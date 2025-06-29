#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -e

# Script variables
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"

# Source common functions if available
if [ -f "$DOTFILES_DIR/scripts/common.sh" ]; then
  source "$DOTFILES_DIR/scripts/common.sh"
else
  # Minimal color definitions if common.sh is not available
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
  
  # Minimal printing functions if common.sh is not available
  print_header() { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }
  print_step() { echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"; }
  print_success() { echo -e "${GREEN}✓${NC} $1"; }
  print_error() { echo -e "${RED}✗${NC} ${BOLD}ERROR:${NC} $1" >&2; exit 1; }
  print_warning() { echo -e "${YELLOW}!${NC} ${BOLD}WARNING:${NC} $1" >&2; }
  print_info() { echo -e "${BLUE}i${NC} $1"; }
fi

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Xcode Command Line Tools
install_xcode_tools() {
  if ! xcode-select -p &>/dev/null; then
    print_step "Installing Xcode Command Line Tools"
    xcode-select --install
    
    # Wait for the installation to complete
    print_info "Please follow the prompts to install Xcode Command Line Tools."
    read -p "Press Enter to continue once the installation is complete..."
  else
    print_info "Xcode Command Line Tools are already installed."
  fi
}

# Install Homebrew
install_homebrew() {
  print_step "Checking for Homebrew installation"
  
  if command_exists brew; then
    print_success "Homebrew is already installed"
  else
    print_step "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ $(uname -m) == "arm64" ]]; then
      # M1/M2 Mac
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      # Intel Mac
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed successfully"
  fi
}

# Update and upgrade Homebrew
update_homebrew() {
  print_step "Updating and upgrading Homebrew"
  brew update
  brew upgrade
  print_success "Homebrew updated and upgraded successfully"
}

# Install packages with Homebrew
install_brew_packages() {
  print_step "Installing Homebrew packages (formulae)"
  
  local formulae=(
    # Core & System
    "git" "zsh" "openssh" "stow" "spaceship"
    
    # Terminal & Shell Tools
    "neovim" "tmux" "htop" "btop" "unzip" "zip" "tar" "gzip" "rsync" "curl" "wget"
    "ripgrep" "fd" "fzf" "bat" "exa" "lsd" "zoxide" "jq" "yq" "tree" 
    
    # Programming Languages & Runtimes
    "python" "node" "go" "rust" "lua" "luarocks" "ruby"
    
    # DevOps Tools
    "docker" "kubectl" "helm" "k9s" "terraform" "ansible" "awscli"
    
    # Git Tools
    "lazygit" "git-delta" "github-cli" "git-lfs"
    
    # Neovim Dependencies
    "make" "cmake" "pkg-config" "gettext"
  )
  
  brew install "${formulae[@]}"
  
  # Special setup for fzf
  if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
    "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
  fi

  print_success "Homebrew packages installed successfully"
}

# Install fonts and applications with Homebrew Cask
install_brew_casks() {
  print_step "Installing applications and fonts via Homebrew Cask"
  
  brew tap homebrew/cask-fonts
  
  local casks=(
    # Fonts
    "font-fira-code-nerd-font"
    "font-jetbrains-mono-nerd-font"
    "font-hack-nerd-font"
    "font-meslo-lg-nerd-font"
    
    # Applications
    "iterm2"
    "visual-studio-code"
    "docker" # Docker Desktop
    "rectangle"
    "alt-tab"
  )
  
  brew install --cask "${casks[@]}"
  print_success "Homebrew Casks installed successfully"
}

# Cleanup
cleanup() {
  print_step "Cleaning up Homebrew"
  brew cleanup
  print_success "Cleanup completed"
}

# Main function
main() {
  print_header "macOS Package Installation"
  
  install_xcode_tools
  install_homebrew
  update_homebrew
  install_brew_packages
  install_brew_casks
  cleanup
  
  print_header "macOS Package Installation Complete!"
  print_info "All required packages and applications have been installed."
}

# Run the main function
main "$@"
