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

# Check if running as root
check_root() {
  if [ "$(id -u)" -eq 0 ]; then
    print_warning "Running as root is not recommended for this script."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_error "Installation aborted."
      exit 1
    fi
  fi
}

# Ensure sudo access
ensure_sudo() {
  if ! command_exists sudo; then
    print_error "sudo is not installed. Please install sudo first."
    exit 1
  fi
  
  if ! sudo -v; then
    print_error "sudo access is required for this script."
    exit 1
  fi
}

# Update package database
update_pacman() {
  print_step "Updating package database"
  sudo pacman -Syu --noconfirm
  print_success "Package database updated"
}

# Install AUR helper
install_aur_helper() {
  print_step "Setting up AUR helper (yay)"
  
  if command_exists yay; then
    print_info "yay is already installed"
    return
  fi

  print_info "Installing yay (AUR helper)"
  sudo pacman -S --needed --noconfirm base-devel git
  
  # Clone and build yay
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
  
  print_success "yay installed successfully"
}

# Install packages from official repositories
install_pacman_packages() {
  print_step "Installing packages from official repositories"
  
  local packages=(
    # Core & System
    "git" "zsh" "openssh" "sudo" "man-db" "man-pages" "stow"
    
    # Terminal & Shell Tools
    "neovim" "tmux" "htop" "btop" "unzip" "zip" "tar" "gzip" "rsync" "curl" "wget"
    "ripgrep" "fd" "fzf" "bat" "exa" "lsd" "zoxide" "jq" "yq" "tree" 
    
    # Programming Languages & Runtimes
    "python" "python-pip" "nodejs" "npm" "go" "rust" "lua" "luarocks"
    
    # DevOps Tools
    "docker" "docker-compose" "kubectl" "helm" "terraform" "ansible"
    
    # Neovim Dependencies
    "xclip" "wl-clipboard" "python-pynvim" "cmake" "gcc" "make" "pkg-config" "unzip"
  )
  
  sudo pacman -S --needed --noconfirm "${packages[@]}"
  print_success "Official repository packages installed"
}

# Install packages from AUR
install_aur_packages() {
  print_step "Installing packages from AUR"
  
  if ! command_exists yay; then
    print_error "yay is not installed. Cannot install AUR packages."
    return 1
  fi
  
  local packages=(
    "k9s"               # Kubernetes TUI
    "lazygit"           # Git TUI
    "github-cli"        # GitHub CLI
    "git-delta"         # Better git diff
    "aws-cli-v2"        # AWS CLI
    "nerd-fonts-fira-code" # Nerd Font for icons
  )
  
  yay -S --needed --noconfirm "${packages[@]}"
  print_success "AUR packages installed"
}

# Configure system services
configure_services() {
  print_step "Configuring system services"
  
  # Docker
  if command_exists docker; then
    print_info "Enabling and starting Docker service"
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    if ! getent group docker | grep -q "\b$USER\b"; then
      sudo usermod -aG docker "$USER"
      print_info "Added user $USER to the docker group. Please log out and back in for this to take effect."
    fi
  fi
  
  print_success "System services configured"
}

# Cleanup
cleanup() {
  print_step "Cleaning up package caches"
  
  # Clean pacman cache
  sudo pacman -Sc --noconfirm
  
  # Clean AUR helper cache
  if command_exists yay; then
    yay -Scc --noconfirm
  fi
  
  print_success "Cleanup completed"
}

# Main function
main() {
  print_header "Arch Linux Package Installation"
  
  check_root
  ensure_sudo
  update_pacman
  install_aur_helper
  install_pacman_packages
  install_aur_packages
  configure_services
  cleanup
  
  print_header "Installation Complete!"
  print_info "All packages have been installed successfully."
  print_info "Please restart your shell or log out and back in for some changes to take effect."
}

# Run the main function
main "$@"
