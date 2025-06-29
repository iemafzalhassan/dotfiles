#!/usr/bin/env bash

# common.sh - Shared utility functions for dotfiles scripts
# Author: iemafzal
# Created: 2025-04-27
# Description: This script provides common functions used across
#              all dotfiles installation and configuration scripts.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
set -o nounset
set -o pipefail

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the dotfiles directory
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Global variables
SUDO_AVAILABLE=false
ASKPASS="${ASKPASS:-}"
INSTALL_LOG="${DOTFILES_DIR}/.install.log"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'
NC='\033[0m' # No Color

#--------------------------------------
# Utility functions
#--------------------------------------

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if a value exists in an array
contains_element() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Check if a string contains a substring
contains_string() {
  local string="$1"
  local substring="$2"
  [[ "$string" == *"$substring"* ]]
}

# Check if a variable is set and not empty
is_set() {
  [[ -n "${1:-}" ]]
}

# Ensure a directory exists
ensure_dir_exists() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1"
    print_success "Created directory: $1"
  fi
}

# Get absolute path
get_abs_path() {
  local path="$1"
  if [[ -d "$path" ]]; then
    (cd "$path" && pwd)
  elif [[ -f "$path" ]]; then
    if [[ "$path" = /* ]]; then
      echo "$path"
    else
      echo "$PWD/${path#./}"
    fi
  else
    echo "$path"
  fi
}

# Check if script is being run on CI
is_ci() {
  [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${TRAVIS:-}" || -n "${GITLAB_CI:-}" ]]
}

# Check if script is being run in a container
is_container() {
  [[ -f /.dockerenv || -f /run/.containerenv || -n "${KUBERNETES_SERVICE_HOST:-}" ]]
}

# Check if script is being run in a virtual machine
is_vm() {
  if [[ "$(uname)" == "Darwin" ]]; then
    # Check for common virtualization on macOS
    system_profiler SPHardwareDataType | grep -q "Model Identifier: VMware\|VirtualBox\|Parallels\|QEMU"
  else
    # Linux VM detection
    [[ -d /proc/vz || -f /sys/hypervisor/uuid || -d /sys/hypervisor/properties ]] || \
    grep -q "^flags.*hypervisor" /proc/cpuinfo
  fi
}

#--------------------------------------
# Logging functions
#--------------------------------------

# Initialize log file
init_log() {
  # Create log directory if it doesn't exist
  mkdir -p "$(dirname "$INSTALL_LOG")"
  
  # Create new log file or append to existing one
  echo "=== Installation Log (${TIMESTAMP}) ===" >> "$INSTALL_LOG"
  echo "System: $(uname -a)" >> "$INSTALL_LOG"
  echo "Date: $(date)" >> "$INSTALL_LOG"
  echo "User: $(whoami)" >> "$INSTALL_LOG"
  echo "====================================" >> "$INSTALL_LOG"
}

# Log a message to the log file
log_message() {
  local level="$1"
  local message="$2"
  echo "[${level}] [$(date +%H:%M:%S)] ${message}" >> "$INSTALL_LOG"
}

# Log error
log_error() {
  log_message "ERROR" "$1"
}

# Log warning
log_warning() {
  log_message "WARNING" "$1"
}

# Log info
log_info() {
  log_message "INFO" "$1"
}

# Log debug (only if DEBUG is set)
log_debug() {
  if [[ -n "${DEBUG:-}" ]]; then
    log_message "DEBUG" "$1"
  fi
}

# Log success
log_success() {
  log_message "SUCCESS" "$1"
}

#--------------------------------------
# Output formatting functions
#--------------------------------------

# Print a header
print_header() {
  echo -e "\n${BOLD}${BLUE}===================================================${NC}"
  echo -e "${BOLD}${BLUE}   $1${NC}"
  echo -e "${BOLD}${BLUE}===================================================${NC}\n"
  log_info "HEADER: $1"
}

# Print a section title
print_section() {
  echo -e "\n${BOLD}${MAGENTA}>>> $1${NC}\n"
  log_info "SECTION: $1"
}

# Print a step
print_step() {
  echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"
  log_info "STEP: $1"
}

# Print a sub-step
print_substep() {
  echo -e "   ${BLUE}-->${NC} $1"
  log_info "SUBSTEP: $1"
}

# Print a success message
print_success() {
  echo -e "${GREEN}✓${NC} $1"
  log_success "$1"
}

# Print an error message
print_error() {
  echo -e "${RED}✗${NC} ${BOLD}ERROR:${NC} $1" >&2
  log_error "$1"
  return 1
}

# Print a warning message
print_warning() {
  echo -e "${YELLOW}!${NC} ${BOLD}WARNING:${NC} $1" >&2
  log_warning "$1"
}

# Print an info message
print_info() {
  echo -e "${BLUE}i${NC} $1"
  log_info "$1"
}

# Print a debug message (only if DEBUG is set)
print_debug() {
  if [[ -n "${DEBUG:-}" ]]; then
    echo -e "${DIM}d${NC} ${DIM}$1${NC}"
    log_debug "$1"
  fi
}

# Print a prompt
print_prompt() {
  echo -e "${BOLD}${YELLOW}?${NC} ${BOLD}$1${NC} ${2:-}"
}

# Print a success header
print_success_header() {
  echo -e "\n${BOLD}${GREEN}✓ $1${NC}\n"
  log_success "HEADER: $1"
}

# Print an error header
print_error_header() {
  echo -e "\n${BOLD}${RED}✗ $1${NC}\n" >&2
  log_error "HEADER: $1"
}

#--------------------------------------
# System detection functions
#--------------------------------------

# Detect operating system
detect_os() {
  local os
  local kernel
  local distro
  local version
  
  kernel="$(uname -s)"
  
  case "$kernel" in
    Linux)
      os="linux"
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro="${ID}"
        version="${VERSION_ID}"
      elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        distro="${DISTRIB_ID,,}"
        version="${DISTRIB_RELEASE}"
      elif [ -f /etc/debian_version ]; then
        distro="debian"
        version="$(cat /etc/debian_version)"
      elif [ -f /etc/redhat-release ]; then
        if grep -q "CentOS" /etc/redhat-release; then
          distro="centos"
        elif grep -q "Fedora" /etc/redhat-release; then
          distro="fedora"
        else
          distro="rhel"
        fi
        version="$(grep -oP '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)"
      elif [ -f /etc/arch-release ]; then
        distro="arch"
        version="rolling"
      else
        distro="unknown"
        version="unknown"
      fi
      ;;
    Darwin)
      os="macos"
      distro="macos"
      version="$(sw_vers -productVersion)"
      ;;
    *)
      os="unknown"
      distro="unknown"
      version="unknown"
      ;;
  esac
  
  echo "$os:$distro:$version"
}

# Detect package manager
detect_package_manager() {
  local os_info
  local os
  local distro
  
  os_info="$(detect_os)"
  os="$(echo "$os_info" | cut -d: -f1)"
  distro="$(echo "$os_info" | cut -d: -f2)"
  
  case "$os" in
    linux)
      case "$distro" in
        ubuntu|debian|mint|pop|elementary|zorin|kali|parrot|raspbian)
          echo "apt"
          ;;
        fedora|rhel|centos|rocky|alma)
          echo "dnf"
          ;;
        arch|manjaro|endeavouros|artix|garuda)
          echo "pacman"
          ;;
        opensuse|suse)
          echo "zypper"
          ;;
        void)
          echo "xbps"
          ;;
        alpine)
          echo "apk"
          ;;
        *)
          if command_exists apt; then
            echo "apt"
          elif command_exists dnf; then
            echo "dnf"
          elif command_exists yum; then
            echo "yum"
          elif command_exists pacman; then
            echo "pacman"
          elif command_exists zypper; then
            echo "zypper"
          elif command_exists xbps-install; then
            echo "xbps"
          elif command_exists apk; then
            echo "apk"
          else
            echo "unknown"
          fi
          ;;
      esac
      ;;
    macos)
      if command_exists brew; then
        echo "brew"
      else
        echo "brew_missing"
      fi
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Get package script name
get_package_script() {
  local os_info
  local os
  local distro
  
  os_info="$(detect_os)"
  os="$(echo "$os_info" | cut -d: -f1)"
  distro="$(echo "$os_info" | cut -d: -f2)"
  
  case "$os" in
    linux)
      case "$distro" in
        ubuntu|debian|mint|pop|elementary|zorin|kali|parrot|raspbian)
          echo "debian.sh"
          ;;
        fedora|rhel|centos|rocky|alma)
          echo "redhat.sh"
          ;;
        arch|manjaro|endeavouros|artix|garuda)
          echo "arch.sh"
          ;;
        *)
          if command_exists apt; then
            echo "debian.sh"
          elif command_exists dnf || command_exists yum; then
            echo "redhat.sh"
          elif command_exists pacman; then
            echo "arch.sh"
          else
            echo "unknown"
          fi
          ;;
      esac
      ;;
    macos)
      echo "macos.sh"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

#--------------------------------------
# Permission handling functions
#--------------------------------------

# Check if user has sudo access
can_sudo() {
  local prompt
  
  if ! command_exists sudo; then
    SUDO_AVAILABLE=false
    return 1
  fi
  
  prompt=$(sudo -nv 2>&1)
  if [ $? -eq 0 ]; then
    # User has sudo privileges and no password is required
    SUDO_AVAILABLE=true
    return 0
  elif echo "$prompt" | grep -q '^sudo:'; then
    # User has sudo privileges but a password is required
    SUDO_AVAILABLE=true
    return 0
  else
    # User does not have sudo privileges
    SUDO_AVAILABLE=false
    return 1
  fi
}

# Run a command with sudo if needed
sudo_run() {
  if [ "$(id -u)" -eq 0 ]; then
    # Already running as root
    "$@"
  elif [ "$SUDO_AVAILABLE" = true ]; then
    # Use sudo
    sudo "$@"
  else
    # No sudo, try to run anyway
    print_warning "Running without sudo: $*"
    "$@"
  fi
}

# Check if running as root
is_root() {
  [ "$(id -u)" -eq 0 ]
}

# Ask for sudo password if necessary
ask_sudo_password() {
  if is_root; then
    return 0
  fi
  
  if ! can_sudo; then
    print_error "This script requires sudo privileges."
    return 1
  fi
  
  if ! sudo -n true 2>/dev/null; then
    print_info "Sudo password required to continue:"
    sudo true
  fi
}

#--------------------------------------
# User interaction functions
#--------------------------------------

# Ask a yes/no question
ask_yes_no() {
  local prompt="$1"
  local default="${2:-y}"
  local options
  local answer
  
  if [ "$default" = "y" ]; then
    options="[Y/n]"
  else
    options="[y/N]"
  fi
  
  if is_ci; then
    # In CI, use the default answer
    echo "$prompt $options (CI mode, assuming default: $default)"
    answer="$default"
  else
    # Ask the user
    print_prompt "$prompt $options" ""
    read -r answer
    
    # Handle empty response (use default)
    if [ -z "$answer" ]; then
      answer="$default"
    fi
  fi
  
  # Normalize answer to lowercase
  answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
  
  if [[ "$answer" =~ ^(y|yes)$ ]]; then
    return 0
  else
    return 1
  fi
}

# Initialize the scripts
init_log
can_sudo
