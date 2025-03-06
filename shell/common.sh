#!/bin/bash
# Common shell configuration for all shells

# Aliases
alias ll="ls -alh"
alias la="ls -A"
alias l="ls"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias k="kubectl"
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias vi="vim"
alias zshconfig="$EDITOR ~/.zshrc"
alias bashconfig="$EDITOR ~/.bashrc"
alias fishconfig="$EDITOR ~/.config/fish/config.fish"
alias dotfiles="cd $HOME/.dotfiles"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"

# Functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick directory navigation
up() {
  local d=""
  local limit=$1
  
  # Default to 1 level up if no parameter provided
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi
  
  for ((i=1;i<=limit;i++)); do
    d="../$d"
  done
  
  # Use cd to navigate up
  cd $d
}

# Create a new directory and enter it
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Find files by name
ff() {
  find . -type f -name "*$1*"
}

# Find directories by name
fd() {
  find . -type d -name "*$1*"
}

# Search for text in files
ft() {
  grep -r "$1" .
}

# Show disk usage of current directory sorted by size
ducks() {
  du -cksh * | sort -hr
}

# Create a backup of a file
bak() {
  cp "$1"{,.bak}
}

# Restore a backup file
unbak() {
  mv "$1" "${1%.bak}"
}

# Get IP address
myip() {
  curl -s https://api.ipify.org
}

# Get local IP address
localip() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ipconfig getifaddr en0
  else
    hostname -I | awk '{print $1}'
  fi
}

# HTTP server in current directory
serve() {
  local port="${1:-8000}"
  if command -v python3 &>/dev/null; then
    python3 -m http.server "$port"
  elif command -v python &>/dev/null; then
    python -m SimpleHTTPServer "$port"
  else
    echo "Python not found. Cannot start server."
  fi
}

# Weather forecast
weather() {
  local city="$1"
  if [ -z "$city" ]; then
    city="London"
  fi
  curl -s "wttr.in/$city?format=3"
}

# Generate a random password
genpass() {
  local length="${1:-16}"
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()' < /dev/urandom | head -c "$length"
  echo
}

# Docker shortcuts
if command -v docker &>/dev/null; then
  # List all docker containers
  alias dps="docker ps"
  # List all docker images
  alias di="docker images"
  # Stop all running containers
  alias dstop="docker stop \$(docker ps -q)"
  # Remove all containers
  alias drm="docker rm \$(docker ps -a -q)"
  # Remove all images
  alias drmi="docker rmi \$(docker images -q)"
  # Docker compose up
  alias dcu="docker-compose up"
  # Docker compose down
  alias dcd="docker-compose down"
fi

# Kubernetes shortcuts
if command -v kubectl &>/dev/null; then
  # Get all pods
  alias kgp="kubectl get pods"
  # Get all services
  alias kgs="kubectl get services"
  # Get all deployments
  alias kgd="kubectl get deployments"
  # Describe pod
  kpd() {
    kubectl describe pod "$1"
  }
  # Get pod logs
  kpl() {
    kubectl logs "$1"
  }
  # Execute command in pod
  kpe() {
    kubectl exec -it "$1" -- "${@:2}"
  }
fi

# Magic Enter function - shows ls and git status when pressing Enter on empty line
magic_enter() {
  if [[ -z $BUFFER ]]; then
    echo ""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "$(ls -la --color=auto)"
      echo ""
      echo "$(git status -u .)"
    else
      echo "$(ls -la --color=auto)"
    fi
    echo ""
    return 0
  fi
  return 1
}