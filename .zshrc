
# ===========================================
# 🌍 Locale settings (ensuring UTF-8 support)
# ===========================================
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# ===========================================
# 🏗️ Dynamic Homebrew path (Intel & Apple Silicon Macs)
# ===========================================
if [[ $(uname -m) == "arm64" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

# ===========================================
# ⚡ Lazy Load Oh My Zsh for Faster Startup
# ===========================================
export ZSH="$HOME/.oh-my-zsh"

# Load Oh My Zsh only if available
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ===========================================
# 🔌 Plugins & Shell Enhancements
# ===========================================
plugins=(git z kubectl terraform fzf)

# Load plugins if available
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

# Initialize zoxide if available
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Use syntax highlighting if available
if [[ -f "$HOME/.fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ===========================================
# 📝 Preferred Editor
# ===========================================
export EDITOR='vim'

# ===========================================
# 🚀 Aliases (Optimized)
# ===========================================

## General Shortcuts
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias cls="clear"
alias ls="eza --icons=always --group-directories-first"
alias ll="ls -la"

## Git Shortcuts
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph"

# ===========================================
# ⌨️ Improve History Navigation
# ===========================================
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^R' history-incremental-search-backward

export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ===========================================
# 🌌 Spaceship Prompt Configuration
# ===========================================
export SPACESHIP_PROMPT_ORDER=(
  user host dir time
  line_sep char
)

export SPACESHIP_CHAR_SYMBOL="❯❯ "
export SPACESHIP_CHAR_COLOR_SUCCESS="green"
export SPACESHIP_CHAR_COLOR_FAILURE="red"

export SPACESHIP_TIME_SHOW=true
export SPACESHIP_TIME_COLOR="yellow"

# Ensure Spaceship is correctly sourced
if [[ -f "$HOMEBREW_PREFIX/opt/spaceship/spaceship.zsh" ]]; then
  source "$HOMEBREW_PREFIX/opt/spaceship/spaceship.zsh"
elif [[ -f "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh" ]]; then
  source "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh"
fi

# ===========================================
# ⚡ Optimize Command Completion
# ===========================================
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ===========================================
# 🛠️ Custom Function for Empty Enter Key Press
# ===========================================
function custom_enter_behavior() {
  if [[ -z $BUFFER ]]; then
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      git status -u .
    else
      ls -al
    fi
    zle reset-prompt
  else
    zle accept-line
  fi
}

zle -N custom_enter_behavior
bindkey "^M" custom_enter_behavior

# ===========================================
# 🎨 Custom Prompt if Spaceship is not available
# ===========================================
if ! command -v spaceship_prompt &>/dev/null && [[ ! -f "$HOMEBREW_PREFIX/opt/spaceship/spaceship.zsh" ]] && [[ ! -f "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh" ]]; then
  # Custom prompt that mimics Spaceship
  autoload -U colors && colors
  
  # Function to get current time
  function prompt_time() {
    echo "%{$fg[yellow]%}$(date +%H:%M:%S)%{$reset_color%}"
  }
  
  # Function to get current directory
  function prompt_dir() {
    echo "%{$fg[blue]%}%~%{$reset_color%}"
  }
  
  # Set the prompt
  PROMPT='%{$fg[green]%}%n%{$reset_color%} at $(prompt_time)
%{$fg[green]%}❯❯%{$reset_color%} '
  
  # Right prompt with directory
  RPROMPT='$(prompt_dir)'
fi