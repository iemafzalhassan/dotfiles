#!/usr/bin/env bash

# setup_lsp.sh - LSP Server setup script for Neovim
# Author: iemafzal
# Created: 2025-04-27
# Description: This script installs and configures LSP servers, formatters, and linters
#              for use with Neovim.

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the dotfiles directory
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source common functions if available
if [ -f "$DOTFILES_DIR/scripts/common.sh" ]; then
  source "$DOTFILES_DIR/scripts/common.sh"
else
  echo "Error: common.sh not found"
  exit 1
fi

# Global variables
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
MASON_BIN_DIR="${NVIM_DATA_DIR}/mason/bin"
NVIM_VERSION=""
HEADLESS_INSTALL=true

#--------------------------------------
# Helper functions
#--------------------------------------

# Run Neovim command
run_nvim_command() {
  local command="$1"
  
  if [ "$HEADLESS_INSTALL" = true ]; then
    # Run headless Neovim
    nvim --headless -c "$command" -c "qa!" || {
      print_warning "Neovim command '$command' failed, but continuing..."
    }
  else
    # Run Neovim in normal mode
    nvim -c "$command"
  fi
}

# Check Neovim version
check_nvim_version() {
  if ! command_exists nvim; then
    print_error "Neovim is not installed. Please install Neovim first."
    exit 1
  fi
  
  NVIM_VERSION=$(nvim --version | head -n 1 | cut -d " " -f 2)
  print_info "Detected Neovim version: $NVIM_VERSION"
  
  # Check that version is at least 0.8.0
  if [[ $(echo "$NVIM_VERSION" | cut -d. -f1) -eq 0 && $(echo "$NVIM_VERSION" | cut -d. -f2) -lt 8 ]]; then
    print_warning "Neovim version $NVIM_VERSION may be too old for LSP features. Version 0.8.0 or higher is recommended."
    if ! ask_yes_no "Continue anyway?" "n"; then
      print_error "Aborting installation."
      exit 1
    fi

#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/scripts/common.sh"

print_header "Setting up LSP servers and tools"

# Check if nvim is installed
if ! command_exists nvim; then
  print_error "Neovim is not installed! Please install it first."
  exit 1
fi

# Ensure nvim plugin directory exists
ensure_dir_exists "$HOME/.local/share/nvim/site/pack/packer/start"

# Install packer.nvim if not already installed
if [ ! -d "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" ]; then
  print_step "Installing packer.nvim..."
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
  print_success "Installed packer.nvim"
fi

# Install plugins
print_step "Installing Neovim plugins..."
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

# Function to install Node.js (required for many LSP servers)
ensure_node() {
  if ! command_exists node; then
    print_step "Node.js not found. Installing..."
    
    # Use nvm if available
    if [ -f "$HOME/.nvm/nvm.sh" ]; then
      print_info "Using nvm to install Node.js..."
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      nvm install --lts
      nvm use --lts
    else
      # Try to install via package manager
      OS=$(detect_os)
      case "$OS" in
        macos)
          print_info "Installing Node.js via Homebrew..."
          brew install node
          ;;
        debian)
          print_info "Installing Node.js via apt..."
          curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
          sudo apt-get install -y nodejs
          ;;
        arch)
          print_info "Installing Node.js via pacman..."
          sudo pacman -S --noconfirm nodejs npm
          ;;
        redhat)
          print_info "Installing Node.js via dnf..."
          curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
          sudo dnf install -y nodejs
          ;;
        *)
          print_error "Unsupported OS for automatic Node.js installation."
          print_info "Please install Node.js manually and try again."
          exit 1
          ;;
      esac
    fi
    
    # Verify Node.js installation
    if ! command_exists node; then
      print_error "Failed to install Node.js."
      exit 1
    fi
    
    print_success "Node.js installed successfully."
  fi
}

# Function to install LSP servers via Mason
install_mason_servers() {
  print_step "Installing Mason LSP servers..."
  
  # Create a temporary file with Lua commands to install servers
  TEMP_SCRIPT=$(mktemp)
  cat > "$TEMP_SCRIPT" << 'EOF'
-- Setup Mason and install LSP servers
require('mason').setup()
require('mason-registry').refresh()

-- List of servers to install
local servers = {
  "lua_ls",         -- Lua
  "pyright",        -- Python
  "bashls",         -- Bash
  "terraformls",    -- Terraform
  "yamlls",         -- YAML
  "jsonls",         -- JSON
  "dockerls",       -- Docker
  "html",           -- HTML
  "cssls",          -- CSS
  "tsserver",       -- TypeScript/JavaScript
  "gopls",          -- Go
  "rust_analyzer",  -- Rust
}

local formatters = {
  "stylua",         -- Lua formatter
  "black",          -- Python formatter
  "isort",          -- Python import formatter
  "prettier",       -- JavaScript/TypeScript/JSON/YAML formatter
  "terraform_fmt",  -- Terraform formatter
  "shfmt",          -- Shell script formatter
  "gofmt",          -- Go formatter
}

local linters = {
  "shellcheck",     -- Shell script linter
  "eslint_d",       -- JavaScript/TypeScript linter
  "flake8",         -- Python linter
  "golangci-lint",  -- Go linter
}

-- Install all servers
local registry = require('mason-registry')
for _, server_name in ipairs(servers) do
  local server = registry.get_package(server_name)
  if not server:is_installed() then
    print("Installing " .. server_name)
    server:install()
  end
end

-- Install formatters
for _, formatter_name in ipairs(formatters) do
  local formatter = registry.get_package(formatter_name)
  if not formatter:is_installed() then
    print("Installing " .. formatter_name)
    formatter:install()
  end
end

-- Install linters
for _, linter_name in ipairs(linters) do
  local linter = registry.get_package(linter_name)
  if not linter:is_installed() then
    print("Installing " .. linter_name)
    linter:install()
  end
end
EOF

  # Run Neovim with the temporary script
  nvim --headless -c "lua dofile('$TEMP_SCRIPT')" -c "qa!"
  
  # Remove the temporary script
  rm "$TEMP_SCRIPT"
  
  print_success "LSP servers installed successfully."
}

# Main execution starts here

# Ensure Node.js is installed
ensure_node

# Install LSP servers
install_mason_servers

print_header "LSP setup completed successfully!"
print_info "Your Neovim development environment is ready to use."
