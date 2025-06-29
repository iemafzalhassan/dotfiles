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
update_dnf() {
  print_step "Updating package lists (dnf update)"
  dnf update -y
  print_success "Package lists updated"
}

# Install prerequisite packages
install_prerequisites() {
  print_step "Installing prerequisites"
  dnf install -y 'dnf-command(config-manager)' dnf-plugins-core
  
  # Enable EPEL for RHEL/CentOS
  if grep -qi "Red Hat\|CentOS" /etc/os-release; then
    print_info "Enabling EPEL repository"
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
  fi
  
  print_success "Prerequisites installed"
}

# Install main packages from DNF
install_dnf_packages() {
  print_step "Installing main packages from DNF"
  
  dnf groupinstall -y "Development Tools"
  
  local packages=(
    # Core & System
    "git" "zsh" "openssh-clients" "sudo" "man-db" "stow" "util-linux-user"
    
    # Terminal & Shell Tools
    "tmux" "htop" "btop" "unzip" "zip" "tar" "gzip" "rsync" "fzf" "jq" "yq" "tree" "ripgrep" "fd-find" "bat"
    
    # Programming Languages & Runtimes
    "python3" "python3-pip" "golang" "rust" "cargo" "lua" "luarocks" "nodejs"
    
    # Neovim Dependencies
    "libtool" "autoconf" "automake" "cmake" "gcc" "gcc-c++" "make" "pkgconfig" "unzip" "xclip"
  )
  
  dnf install -y "${packages[@]}"
  print_success "Main DNF packages installed"
}

# Install packages that need external repos or special handling
install_special_packages() {
  print_step "Installing special packages (Neovim, Docker, etc.)"

  # Neovim (from Copr repo for latest version)
  if ! command_exists nvim; then
    print_info "Adding Neovim COPR repository"
    dnf copr enable -y agriffis/neovim-nightly
    dnf install -y neovim python3-neovim
  fi

  # Docker
  if ! command_exists docker; then
    print_info "Setting up Docker repository"
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  fi

  # GitHub CLI
  if ! command_exists gh; then
    print_info "Setting up GitHub CLI repository"
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
    dnf install -y gh
  fi
  
  # Terraform
  if ! command_exists terraform; then
    print_info "Setting up HashiCorp repository for Terraform"
    dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    dnf install -y terraform
  fi

  # kubectl
  if ! command_exists kubectl; then
    print_info "Installing kubectl"
    cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
    dnf install -y kubectl
  fi

  # Helm
  if ! command_exists helm; then
    print_info "Installing Helm"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm ./get_helm.sh
  fi
  
  # Install modern shell tools via binary/script if not in standard repos
  install_modern_shell_tools
}

# Install modern replacements for core utils
install_modern_shell_tools() {
    print_step "Installing/Updating modern shell tools"

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
        # Not easily available via package, install via cargo if possible
        if command_exists cargo; then
          cargo install git-delta
        else
          print_warning "cargo not found, cannot install git-delta. Please install Rust."
        fi
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
  dnf autoremove -y
  dnf clean all
  print_success "Cleanup completed"
}

main() {
  print_header "RHEL/Fedora Package Installation"
  
  ensure_sudo
  update_dnf
  install_prerequisites
  install_dnf_packages
  install_special_packages
  configure_services
  cleanup
  
  print_header "Installation Complete!"
  print_info "All packages have been installed successfully."
  print_info "Please restart your shell or log out and back in for some changes to take effect."
}

# Run the main function
main "$@"

