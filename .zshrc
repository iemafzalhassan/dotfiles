# ===== PERFORMANCE MONITORING =====
# Enable profiling with: ZSH_PROFILE=1 zsh
if [[ "$ZSH_PROFILE" == "1" ]]; then
    zmodload zsh/zprof
fi
# ===== OPTIMIZED PATH CONFIGURATION =====
# Build PATH array once for better performance
typeset -U path
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.local/bin
  $HOME/bin
  /opt/homebrew/opt/coreutils/libexec/gnubin
  /opt/homebrew/opt/grep/libexec/gnubin
  $HOME/.npm-global/bin
  $HOME/.codeium/windsurf/bin
  $HOME/.sdkman/candidates/maven/current/bin
  $HOME/.sdkman/candidates/java/current/bin
  /Applications/Windsurf.app/Contents/Resources/app/bin
  /Applications/Antigravity.app/Contents/Resources/app/bin
  /Applications/Docker.app/Contents/Resources/bin
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)
export PATH

# Homebrew configuration
# Hide one-time env hint messages like HOMEBREW_NO_ENV_HINTS
export HOMEBREW_NO_ENV_HINTS=1

# Detect Homebrew prefix (macOS: /opt/homebrew or /usr/local; Linux: /home/linuxbrew/.linuxbrew)
if [ -x /opt/homebrew/bin/brew ]; then
  HOMEBREW_PREFIX="/opt/homebrew"
elif [ -x /usr/local/bin/brew ]; then
  HOMEBREW_PREFIX="/usr/local"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
else
  HOMEBREW_PREFIX=""
fi

# Set JAVA_HOME if SDKMAN Java is available
if [ -d "$HOME/.sdkman/candidates/java/current" ]; then
    export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
fi

# Configure dircolors for file highlighting (only if available)
if command -v dircolors >/dev/null 2>&1; then
  if [[ -f ~/.dircolors ]]; then
      eval "$(dircolors -b ~/.dircolors)"
  else
      eval "$(dircolors -b)"
  fi
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
ZSH_THEME="spaceship"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# Auto-update runs extra work during shell init
zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
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
# Essential plugins loaded immediately
plugins=(docker kubectl terraform gcloud history-substring-search zsh-syntax-highlighting zsh-autosuggestions web-search gh aliases kubectx docker-compose helm httpie procs systemadmin brew tldr task taskwarrior tmux thefuck)

# ===== SPACESHIP THEME CONFIGURATION =====
# Locale must be set before Oh My Zsh loads the theme
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# All Spaceship settings live in spaceship/config.zsh (repo) -> ~/.config/spaceship/config.zsh
[[ -f "$HOME/.config/spaceship/config.zsh" ]] && source "$HOME/.config/spaceship/config.zsh"

# Docker CLI completions — in fpath BEFORE Oh My Zsh loads, so its single compinit picks them up
fpath=($HOME/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# User configuration

# Enhanced history configuration
HISTSIZE=10000                    # How many lines of history to keep in memory
SAVEHIST=10000                    # Number of history entries to save to disk
HISTFILE=~/.zsh_history           # Where to save history to disk
setopt HIST_EXPIRE_DUPS_FIRST     # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS           # Ignore duplicated commands in history list
setopt HIST_IGNORE_SPACE          # Ignore commands that start with space
setopt HIST_VERIFY                # Show command with history expansion to user before running it
setopt SHARE_HISTORY              # Share command history data between sessions

# Disable zsh spelling correction prompts like "correct 'cmd' to 'other'?"
unsetopt correct correct_all

# Directory stack configuration
setopt AUTO_PUSHD                  # Push the current directory onto the stack
setopt PUSHD_IGNORE_DUPS           # Do not store duplicates in the stack
setopt PUSHD_SILENT                # Do not print the directory stack after pushd or popd
alias d='dirs -v'                  # List recent directories
for index ({1..9}) alias "$index"="cd +${index}"; unset index  # Access recent directories using numbers 1-9

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

# Find process using a specific port
port() {
  lsof -i ":$1" | grep LISTEN
}



# ===== OPTIMIZED GIT CONFIGURATION =====
# Git with delta for better diff and log viewing
export GIT_PAGER="delta"
# Note: Git configuration is handled in ~/.gitconfig for better performance

# Make vi and vim use nvim
alias vi='nvim'
alias vim='nvim'
export EDITOR='nvim'


# Initialize zoxide
if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd z)"
fi

# ========= FZF CONFIGURATION =========
export FZF_BASE="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf"

# Smart FZF command selection
if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # Enhanced ripgrep-fzf alias
    alias rgf='rg --color=always --line-number --no-heading --smart-case | fzf --ansi --color "hl:-1:underline,hl+:-1:underline:reverse" --delimiter : --preview "bat --color=always {1} --highlight-line {2} || cat {1}" --preview-window "up,60%,border-bottom,+{2}+3/3,~3" | cut -d: -f1 | xargs -r ${EDITOR:-vim}'
else
    export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/\.*' 2>/dev/null"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Smart preview configuration with performance optimizations
if command -v bat >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}' --bind='change:top' --no-mouse --cycle --ansi --exact"
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
else
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'cat {}' --bind='change:top' --no-mouse --cycle --ansi --exact"
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
fi

# Smart directory preview
if command -v eza >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'eza -la --icons --group-directories-first {}'"
else
    export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}'"
fi

# FZF configuration
# Enable menu selection for all completions
zstyle ':completion:*' menu select

# Enhanced ls commands with eza
export TERM=xterm-256color
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --icons --level=2'
  alias ltg='eza --tree --icons --git-ignore'
  alias tree='eza --tree --icons --level=2 --git-ignore'
  alias treeall='eza --tree --icons --level=3'
else
  alias ls='ls --color=auto'
  alias l='ls -l'
  alias la='ls -la'
  alias ll='ls -l'
fi

# FZF directory navigator with cd
fcd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m --height 30% --border --header='[cd:directory]')
    if [[ -n "$dir" ]]; then
        cd "$dir"
    fi
}

# FZF file opener
fopen() {
    local file
    file=$(fzf --height 30% --border --header='[open:file]')
    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file"
    fi
}

# FZF environment variable viewer
fenv() {
    printenv | fzf --height 30% --border --header='[env:variables]' --preview 'echo {}'
}

# FZF tmux session manager
ftmux() {
    if command -v tmux >/dev/null 2>&1; then
        local session
        session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --height 30% --border --header='[tmux:session]')
        if [[ -n "$session" ]]; then
            tmux attach -t "$session"
        fi
    fi
}


# FZF aliases for quick access
alias ff='fopen'               # Find and open file
alias fe='fenv'                # Environment variables
alias ft='ftmux'               # Tmux sessions

# ===== NVM CONFIGURATION (HOMEBREW) =====
# Load NVM during shell startup so all globally installed
# Node.js CLIs (gsd, npm, pnpm, claude, vite, etc.)
# are immediately available in every terminal.

export NVM_DIR="$HOME/.nvm"

# Load NVM (Homebrew on macOS, standalone ~/.nvm on Linux)
if [ -n "${HOMEBREW_PREFIX:-}" ] && [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
  . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

# Load bash completion (optional)
[ -n "${HOMEBREW_PREFIX:-}" ] && [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# Automatically activate your default Node version
command -v nvm >/dev/null 2>&1 && nvm use default >/dev/null 2>&1

# ===== UTILITY FUNCTIONS =====
# System info with neofetch
alias sysinfo='neofetch'

# Lazygit and Lazydocker
alias lg='lazygit'
alias ld='lazydocker'

# Antigravity shortcut

# ===== ENHANCED ALIASES =====

# Enhanced man with tldr (smart replacement)
if command -v tldr >/dev/null 2>&1; then
    alias man='tldr'
fi

# Enhanced cat with bat (smart replacement)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi


# ===== PROMPT ENHANCEMENTS =====
# Spaceship styling is now handled in the optimized configuration above
# (Avoid printing during shell init; it can break non-interactive tooling.)

if [[ -o interactive && -t 1 ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

  # Load FZF key bindings and completion (OFFICIAL INTEGRATION)
  [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
  [ -n "${HOMEBREW_PREFIX:-}" ] && [ -f "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
fi

# Lazy load SDKMAN
sdk() {
    unset -f sdk
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
    sdk "$@"
}

# Ruby compilation flags
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# ===== API KEYS =====
# NOTE: Real key values live ONLY in ~/.zshrc.local (gitignored) — never commit real keys.
# The lines below are placeholders; replace with your own values or set them in ~/.zshrc.local.
export ADEN_API_KEY="REPLACE_WITH_YOUR_ADEN_API_KEY"

export OPENROUTER_API_KEY="REPLACE_WITH_YOUR_OPENROUTER_API_KEY"
export ANTHROPIC_BASE_URL="http://127.0.0.1:3456/v1"
export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
export ANTHROPIC_API_KEY="$OPENROUTER_API_KEY"
export CLAUDE_CODE_MODEL="claude-3-5-sonnet-20241022"
export GITHUB_PERSONAL_ACCESS_TOKEN="REPLACE_WITH_YOUR_GITHUB_TOKEN"

# Load local-only overrides & secrets (never committed to git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
# Added by Antigravity IDE
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
export KUBECONFIG=~/k3s.yaml
alias mp="multipass"


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
