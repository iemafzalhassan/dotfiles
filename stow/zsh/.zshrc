# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# ===== PATH Configuration =====
# Initialize PATH with standard system paths if empty
if [ -z "$PATH" ]; then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
fi

# Add user's local bin directories if they exist
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/bin" ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
fi

# Add Homebrew to PATH if it exists
if [ -d "/opt/homebrew/bin" ] && [[ ":$PATH:" != *"/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

if [ -d "/opt/homebrew/sbin" ] && [[ ":$PATH:" != *"/opt/homebrew/sbin:"* ]]; then
    export PATH="/opt/homebrew/sbin:$PATH"
fi

# Add GNU core utilities to PATH
if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ] && [[ ":$PATH:" != *"/opt/homebrew/opt/coreutils/libexec/gnubin:"* ]]; then
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi

# Add GNU grep to PATH
if [ -d "/opt/homebrew/opt/grep/libexec/gnubin" ] && [[ ":$PATH:" != *"/opt/homebrew/opt/grep/libexec/gnubin:"* ]]; then
    export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
elif [ -d "/opt/homebrew/Cellar/grep/3.12/libexec/gnubin" ] && [[ ":$PATH:" != *"/opt/homebrew/Cellar/grep/3.12/libexec/gnubin:"* ]]; then
    export PATH="/opt/homebrew/Cellar/grep/3.12/libexec/gnubin:$PATH"
fi

# Add Windsurf to PATH
if [ -d "$HOME/.codeium/windsurf/bin" ] && [[ ":$PATH:" != *":$HOME/.codeium/windsurf/bin:"* ]]; then
    export PATH="$HOME/.codeium/windsurf/bin:$PATH"
fi

# Set FUNCNEST to a higher value to prevent "maximum nested function level reached" errors
export FUNCNEST=10000

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting history-substring-search docker kubectl terraform aws fzf sudo web-search copypath dirhistory z fzf-tab)

source $ZSH/oh-my-zsh.sh

# User configuration

# Enhanced history configuration
HISTSIZE=50000               # How many lines of history to keep in memory
SAVEHIST=50000               # Number of history entries to save to disk
HISTFILE=~/.zsh_history      # Where to save history to disk
setopt HIST_EXPIRE_DUPS_FIRST    # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS           # Ignore duplicated commands in history list
setopt HIST_IGNORE_SPACE          # Ignore commands that start with space
setopt HIST_VERIFY                # Show command with history expansion to user before running it
setopt SHARE_HISTORY              # Share command history data between sessions

# Directory stack configuration
setopt AUTO_PUSHD                  # Push the current directory onto the stack
setopt PUSHD_IGNORE_DUPS           # Do not store duplicates in the stack
setopt PUSHD_SILENT                # Do not print the directory stack after pushd or popd
alias d='dirs -v'                  # List recent directories
for index ({1..9}) alias "$index"="cd +${index}"; unset index  # Access recent directories using numbers 1-9

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Useful development functions

# Extract various compressed file types
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

# Create a new directory and enter it
mkcd() {
  mkdir -p "$@" && cd "$_";
}

# Find process using a specific port
port() {
  lsof -i ":$1" | grep LISTEN
}

# Display all IP addresses
myip() {
  echo "Public IP: $(curl -s ifconfig.me)"
  echo "Local IPs:"
  ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print "  " $2}'
}

# Kubernetes context switch with fzf
kctxf() {
  local context=$(kubectl config get-contexts -o name | fzf --height 30% --border)
  if [[ -n "$context" ]]; then
    kubectl config use-context "$context"
  fi
}

# Kubernetes namespace switch with fzf
knsf() {
  local namespace=$(kubectl get namespaces -o name | cut -d/ -f2 | fzf --height 30% --border)
  if [[ -n "$namespace" ]]; then
    kubectl config set-context --current --namespace "$namespace"
    echo "Switched to namespace: $namespace"
  fi
}

# Git commit with branch name prefix
gcbp() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git commit -m "[$branch] $*"
  else
    echo "Not in a git repository or no commit message provided"
  fi
}

# Get AWS EC2 instance details
ec2details() {
  aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" \
    --query "Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key=='Name'].Value|[0],Type:InstanceType,State:State.Name,IP:PrivateIpAddress,PublicIP:PublicIpAddress}" \
    --output table
}

# Aliases
# Add GNU grep to PATH
export PATH="/opt/homebrew/Cellar/grep/3.12/libexec/gnubin:$PATH"

# ----- DevOps aliases --------
# Kubernetes context and namespace management
alias kctx='kubectl config get-contexts'
alias kctxs='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Kubernetes logs and exec
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'

# Kubernetes port-forwarding
alias kpf='kubectl port-forward'

# Kubernetes apply and delete
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgn='kubectl get nodes'
alias kgns='kubectl get namespaces'
alias kgrs='kubectl get replicasets'
alias kgr='kubectl get replicas'
alias kgsa='kubectl get statefulsets'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kdpo='kubectl describe pod'
alias kdrs='kubectl describe replicaset'

# AWS shortcuts
alias awsid='aws sts get-caller-identity'
alias awsls='aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],Type:InstanceType,State:State.Name,IP:PrivateIpAddress}" --output table'

# Docker cleanup
alias dprune='docker system prune -af'
alias dclean='docker rm -f $(docker ps -aq) 2>/dev/null || echo "No containers to remove"'

# Quick SSH with key
alias sshkey='ssh -i ~/.ssh/id_rsa'

# Docker aliases
alias d='docker'
alias dc='docker-compose'

# Terraform aliases
alias tf='terraform'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfp='terraform plan'
alias tfd='terraform destroy'
alias tfda='terraform destroy -auto-approve'
alias tfi='terraform init'
alias tfv='terraform validate'
alias tff='terraform fmt'

# Git aliases (in addition to Oh My Zsh git plugin)
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gc='git commit'
alias gco='git checkout'
alias gcb='git checkout -b'

# Git with delta for better diff and log viewing
export GIT_PAGER="delta"

# Configure git to use delta by default
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global delta.decorations true

# Configure git to use difftastic for structural diffs
git config --global diff.external "difft"
# Alias for difftastic
alias gds='git difftool --no-symlinks --dir-diff'

# Make vi and vim use nvim
alias vi='nvim'
alias vim='nvim'
export EDITOR='nvim'

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Spaceship prompt configuration
source /opt/homebrew/opt/spaceship/spaceship.zsh
[[ -f "$HOME/.config/spaceship/config.zsh" ]] && source "$HOME/.config/spaceship/config.zsh"
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# Added by Windsurf
export PATH="/Users/iemafzal/.codeium/windsurf/bin:$PATH"

# Initialize zoxide (smarter cd command) with enhanced configuration
# Only initialize zoxide if installed
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# FZF configuration and sourcing
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF enhanced configuration
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}'"

# FZF-tab configuration
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# show file preview using bat
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath || ls -la $realpath'

# Enhanced ls commands with icons - explicitly set terminal type
export TERM=xterm-256color

# Enhanced ls commands with icons or fallback to standard ls
if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd --icon=always --group-dirs first'
    alias l='lsd -l --icon=always --group-dirs first'
    alias la='lsd -la --icon=always --group-dirs first'
    alias lt='lsd --tree --icon=always --group-dirs first'
    alias ll='lsd -l --icon=always --group-dirs first'
else
    # Fallback to standard ls with colors
    alias ls='ls --color=auto'
    alias l='ls -l'
    alias la='ls -la'
    alias ll='ls -l'
fi

# Add color to man pages
export LESS_TERMCAP_md=$'\e[01;34m'      # Bold - blue
export LESS_TERMCAP_me=$'\e[0m'          # End mode
export LESS_TERMCAP_se=$'\e[0m'          # End standout-mode
export LESS_TERMCAP_so=$'\e[01;44;33m'   # Standout-mode - yellow on blue
export LESS_TERMCAP_ue=$'\e[0m'          # End underline
export LESS_TERMCAP_us=$'\e[01;32m'      # Begin underline - green

# fzf enhancement - search history with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Custom FZF history search with safe preview
fzf-history-widget() {
  # Use FZF to search history, previewing the command itself
  local selected
  selected=$(fc -rl 1 | fzf --tac --no-sort --preview "echo {}" --height 40% --border --layout=reverse --prompt='History> ')
  if [[ -n "$selected" ]]; then
    # Remove the leading history number and whitespace
    selected="${selected#* }"
    # Paste the command into the prompt
    print -z -- "$selected"
  fi
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget  # Ctrl+R to trigger

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/iemafzal/.lmstudio/bin"

# Bat (cat replacement) configuration
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias cat='bat --paging=never'
alias catp='bat'

# Lazygit and Lazydocker
alias lg='lazygit'
alias ld='lazydocker'

# GitHub CLI aliases
if [[ -x "$(command -v gh)" ]]; then
  alias ghr='gh repo'
  alias ghpr='gh pr'
  alias ghi='gh issue'
  alias ghc='gh repo create'
  alias ghv='gh repo view --web'
fi


# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
export PATH=~/.npm-global/bin:$PATH

# Task Master aliases added on 29/06/2025
alias tm='task-master'
alias taskmaster='task-master'
