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

# Ensure script is run with sudo
ensure_sudo() {
  if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run with sudo or as root."
    exit 1
  fi
}

# Update package manager
update_apt() {
  print_step "Updating package lists (apt-get update)"
  apt-get update
  print_success "Package lists updated"
}

# Install prerequisite packages for adding repositories
install_prerequisites() {
  print_step "Installing prerequisites for managing repositories"
  apt-get install -y \
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
  print_success "Prerequisites installed"
}

# Install main packages from APT
install_apt_packages() {
  print_step "Installing main packages from APT"
  
  local packages=(
    # Core & System
    "build-essential" "zsh" "openssh-client" "sudo" "man-db" "stow"
    
    # Terminal & Shell Tools
    "tmux" "htop" "btop" "unzip" "zip" "tar" "gzip" "rsync" "fzf" "jq" "yq" "tree"
    
    # Programming Languages & Runtimes
    "python3" "python3-pip" "python3-venv" "golang" "rustc" "cargo" "lua5.3" "liblua5.3-dev" "luarocks"
    
    # Neovim Dependencies
    "gettext" "libtool" "libtool-bin" "autoconf" "automake" "cmake" "g++" "pkg-config" "unzip" "xclip"
  )
  
  apt-get install -y "${packages[@]}"
  print_success "Main APT packages installed"
}

# Install packages that might need external repos or special handling
install_special_packages() {
  print_step "Installing special packages (Neovim, Docker, etc.)"

  # Node.js (from NodeSource)
  if ! command_exists node; then
    print_info "Setting up NodeSource repository for Node.js"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
  fi

  # Neovim (latest stable)
  if ! command_exists nvim; then
    print_info "Adding Neovim PPA"
    add-apt-repository -y ppa:neovim-ppa/stable
    apt-get update
    apt-get install -y neovim
  fi

  # Docker
  if ! command_exists docker; then
    print_info "Setting up Docker repository"
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  fi

  # GitHub CLI
  if ! command_exists gh; then
    print_info "Setting up GitHub CLI repository"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    apt-get update
    apt-get install -y gh
  fi
  
  # Terraform
  if ! command_exists terraform; then
    print_info "Setting up HashiCorp repository for Terraform"
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    apt-get update
    apt-get install -y terraform
  fi

  # kubectl
  if ! command_exists kubectl; then
    print_info "Installing kubectl"
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
    apt-get update
    apt-get install -y kubectl
  fi

  # Helm
  if ! command_exists helm; then
    print_info "Installing Helm"
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
    apt-get update
    apt-get install -y helm
  fi
  
  # Install modern shell tools via binary/script if not in standard repos
  install_modern_shell_tools
}

# Install modern replacements for core utils that might not be in apt repos
install_modern_shell_tools() {
    print_step "Installing/Updating modern shell tools"

    # ripgrep, fd-find, bat
    apt-get install -y ripgrep fd-find bat
    # Create symlinks for fd and bat if they don't exist
    if ! command_exists fd; then ln -s "$(which fdfind)" /usr/local/bin/fd; fi
    if ! command_exists bat; then ln -s "$(which batcat)" /usr/local/bin/bat; fi

    # lazygit
    if ! command_exists lazygit; then
        print_info "Installing lazygit"
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit
        rm /tmp/lazygit.tar.gz
    fi

    # git-delta
    if ! command_exists delta; then
        print_info "Installing git-delta"
        DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        curl -Lo /tmp/git-delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
        dpkg -i /tmp/git-delta.deb
        rm /tmp/git-delta.deb
    fi
    
    # zoxide
    if ! command_exists zoxide; then
      print_info "Installing zoxide"
      curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
}


# Configure system services
configure_services() {
  print_step "Configuring system services"
  
  # Docker
  if command_exists docker; then
    print_info "Enabling and starting Docker service"
    systemctl enable docker.service
    systemctl start docker.service
    if ! getent group docker | grep -q "\b$USER\b"; then
      usermod -aG docker "${SUDO_USER:-$USER}"
      print_info "Added user ${SUDO_USER:-$USER} to the docker group. Please log out and back in for this to take effect."
    fi
  fi
  
  print_success "System services configured"
}

# Cleanup
cleanup() {
  print_step "Cleaning up"
  apt-get autoremove -y
  apt-get clean
  print_success "Cleanup completed"
}

main() {
  print_header "Debian/Ubuntu Package Installation"
  
  ensure_sudo
  update_apt
  install_prerequisites
  install_apt_packages
  install_special_packages
  configure_services
  cleanup
  
  print_header "Installation Complete!"
  print_info "All packages have been installed successfully."
  print_info "Please restart your shell or log out and back in for some changes to take effect."
}

# Run the main function
main "$@"
