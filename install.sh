#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -e

# Print each command before executing (helpful for debugging)
# set -x

# Script variables
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Source common functions if available
if [ -f "$DOTFILES_DIR/scripts/common.sh" ]; then
  source "$DOTFILES_DIR/scripts/common.sh"
fi

# Print section header
print_header() {
  echo -e "\n${BOLD}${BLUE}===================================================${NC}"
  echo -e "${BOLD}${BLUE}   $1${NC}"
  echo -e "${BOLD}${BLUE}===================================================${NC}\n"
}

# Print step information
print_step() {
  echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"
}

# Print success message
print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

# Print error message and exit
print_error() {
  echo -e "${RED}✗${NC} ${BOLD}ERROR:${NC} $1" >&2
  exit 1
}

# Print warning message
print_warning() {
  echo -e "${YELLOW}!${NC} ${BOLD}WARNING:${NC} $1" >&2
}

# Print info message
print_info() {
  echo -e "${BLUE}i${NC} $1"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Create backup of existing file
backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    print_info "Backing up $file"
    mkdir -p "$BACKUP_DIR/$(dirname "$file" | sed "s|^$HOME/||")"
    cp -R "$file" "$BACKUP_DIR/$(echo "$file" | sed "s|^$HOME/||")"
    return 0
  fi
  return 1
}

# Create symlink
create_symlink() {
  local source_file="$1"
  local target_file="$2"
  
  if [ ! -e "$source_file" ]; then
    print_error "Source file $source_file does not exist"
  fi
  
  if [ -e "$target_file" ]; then
    if [ -L "$target_file" ]; then
      print_info "Removing existing symlink $target_file"
      rm "$target_file"
    else
      backup_file "$target_file"
      print_info "Removing existing file $target_file"
      rm -rf "$target_file"
    fi
  fi
  
  mkdir -p "$(dirname "$target_file")"
  ln -sf "$source_file" "$target_file"
  print_success "Created symlink $target_file -> $source_file"
}

# Detect operating system
detect_os() {
  print_header "Detecting Operating System"
  
  if [ "$(uname)" == "Darwin" ]; then
    print_success "macOS detected"
    OS="macos"
  elif [ -f /etc/os-release ]; then
    source /etc/os-release
    
    if [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
      print_success "Debian-based system detected (${PRETTY_NAME})"
      OS="debian"
    elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
      print_success "Arch-based system detected (${PRETTY_NAME})"
      OS="arch"
    elif [[ "$ID" == "fedora" || "$ID" == "rhel" || "$ID_LIKE" == *"fedora"* || "$ID_LIKE" == *"rhel"* ]]; then
      print_success "RHEL-based system detected (${PRETTY_NAME})"
      OS="redhat"
    else
      print_warning "Unsupported Linux distribution: ${PRETTY_NAME}"
      print_info "Defaulting to Debian-based installation methods"
      OS="debian"
    fi
  else
    print_error "Unsupported operating system"
    exit 1
  fi
  
  return 0
}

# Install required dependencies
install_dependencies() {
  print_header "Installing Dependencies"
  
  if [ ! -f "$DOTFILES_DIR/packages/$OS.sh" ]; then
    print_error "Package installation script for $OS not found"
    exit 1
  fi
  
  print_step "Running package installation script for $OS"
  
  chmod +x "$DOTFILES_DIR/packages/$OS.sh"
  bash "$DOTFILES_DIR/packages/$OS.sh"
  
  print_success "Dependencies installed successfully"
}

# Install Oh My Zsh
install_oh_my_zsh() {
  print_header "Setting up Oh My Zsh"
  
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_info "Oh My Zsh is already installed, skipping installation"
  else
    print_step "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed successfully"
  fi
  
  # Install custom plugins
  print_step "Installing custom plugins"
  
  ZSH_PLUGINS_DIR="$ZSH_CUSTOM/plugins"
  mkdir -p "$ZSH_PLUGINS_DIR"
  
  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    print_success "Installed zsh-syntax-highlighting"
  else
    print_info "zsh-syntax-highlighting is already installed"
  fi
  
  # zsh-autosuggestions
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    print_success "Installed zsh-autosuggestions"
  else
    print_info "zsh-autosuggestions is already installed"
  fi
  
  # zsh-history-substring-search
  if [ ! -d "$ZSH_PLUGINS_DIR/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH_PLUGINS_DIR/zsh-history-substring-search"
    print_success "Installed zsh-history-substring-search"
  else
    print_info "zsh-history-substring-search is already installed"
  fi
  
  print_success "Oh My Zsh setup completed"
}

# Install Spaceship Prompt
install_spaceship_prompt() {
  print_header "Setting up Spaceship Prompt"
  
  ZSH_THEMES_DIR="$ZSH_CUSTOM/themes"
  mkdir -p "$ZSH_THEMES_DIR"
  
  if [ ! -d "$ZSH_THEMES_DIR/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_THEMES_DIR/spaceship-prompt" --depth=1
    ln -sf "$ZSH_THEMES_DIR/spaceship-prompt/spaceship.zsh-theme" "$ZSH_THEMES_DIR/spaceship.zsh-theme"
    print_success "Installed Spaceship Prompt"
  else
    print_info "Spaceship Prompt is already installed"
  fi
  
  print_success "Spaceship Prompt setup completed"
}

# Set up Neovim
setup_neovim() {
  print_header "Setting up Neovim"
  
  if ! command_exists nvim; then
    print_error "Neovim is not installed. Please run the package installation script first."
    exit 1
  fi
  
  print_step "Creating Neovim configuration directory"
  mkdir -p "$CONFIG_DIR"
  
  print_step "Linking Neovim configuration"
  create_symlink "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"
  
  # Install Packer (Neovim plugin manager)
  print_step "Installing Packer (Neovim plugin manager)"
  PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
  if [ ! -d "$PACKER_DIR" ]; then
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
    print_success "Installed Packer"
  else
    print_info "Packer is already installed"
  fi
  
  # Install Neovim plugins
  print_step "Installing Neovim plugins"
  nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || true
  
  # Setup LSP servers
  if [ -f "$DOTFILES_DIR/scripts/setup_lsp.sh" ]; then
    print_step "Setting up LSP servers"
    chmod +x "$DOTFILES_DIR/scripts/setup_lsp.sh"
    bash "$DOTFILES_DIR/scripts/setup_lsp.sh"
  else
    print_warning "LSP setup script not found. LSP servers need to be installed manually."
  fi
  
  print_success "Neovim setup completed"
}

# Set up Zsh configuration
setup_zsh() {
  print_header "Setting up Zsh Configuration"
  
  if ! command_exists zsh; then
    print_error "Zsh is not installed. Please run the package installation script first."
    exit 1
  fi
  
  # Create symlink for .zshrc
  print_step "Linking Zsh configuration"
  create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  
  # Create config directory for spaceship if needed
  mkdir -p "$HOME/.config/spaceship"
  if [ -f "$DOTFILES_DIR/zsh/spaceship.zsh" ]; then
    create_symlink "$DOTFILES_DIR/zsh/spaceship.zsh" "$HOME/.config/spaceship/config.zsh"
  fi

  print_success "Zsh configuration setup completed"
}

# Set up Git configuration
setup_git() {
  print_header "Setting up Git Configuration"
  
  if ! command_exists git; then
    print_error "Git is not installed. Please run the package installation script first."
    exit 1
  fi
  
  if [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
    print_step "Linking Git configuration"
    create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  else
    print_warning "Git configuration file not found. Skipping Git setup."
  fi
  
  if [ -f "$DOTFILES_DIR/git/.gitignore_global" ]; then
    print_step "Linking global gitignore"
    create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
    git config --global core.excludesfile "$HOME/.gitignore_global"
  fi
  
  print_success "Git configuration setup completed"
}

# Main installation function
main() {
  print_header "Starting Dotfiles Installation"
  
  mkdir -p "$BACKUP_DIR"
  print_info "Backup directory: $BACKUP_DIR"
  
  # Detect operating system
  detect_os
  
  # Install dependencies
  install_dependencies
  
  # Install Oh My Zsh
  install_oh_my_zsh
  
  # Install Spaceship Prompt
  install_spaceship_prompt
  
  # Set up Zsh configuration
  setup_zsh
  
  # Set up Neovim
  setup_neovim
  
  # Set up Git configuration
  setup_git
  
  print_header "Installation Complete!"
  print_info "Your previous configuration files (if any) have been backed up to: $BACKUP_DIR"
  print_info "Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
  print_info "Enjoy your new development environment!"
}

# Run the main function
main "$@"

