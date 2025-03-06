# Exit if not an interactive shell
case $- in
  *i*) ;;
    *) return;;
esac

# Fix locale issue
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# Set Oh My Bash path
export OSH="$HOME/.oh-my-bash"

# Set Bash Theme
OSH_THEME="font"

# Load Oh My Bash
source "$OSH/oh-my-bash.sh"

# Expand Bash plugins to match Zsh functionality
plugins=(
  git
  aws
  docker
  docker-compose
  kubectl
  helm
  terraform
  golang
  node
  python
  history
  extract
)

# Load Plugins (Only if they exist)
for plugin in "${plugins[@]}"; do
  if [ -f "$OSH/plugins/$plugin/$plugin.plugin.sh" ]; then
    source "$OSH/plugins/$plugin/$plugin.plugin.sh"
  fi
done

# Load common aliases and functions
if [ -f "$HOME/.dotfiles/shell/common.sh" ]; then
  source "$HOME/.dotfiles/shell/common.sh"
fi

# Bash-specific aliases
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias ls="eza --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"
alias bashconfig="vim ~/.bashrc"

# ✅ Smart Navigation (Using Zoxide)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi

# ✅ Autosuggestions (for Bash)
if [ -f "/usr/share/bash-autosuggestions/bash-autosuggestions.sh" ]; then
  source "/usr/share/bash-autosuggestions/bash-autosuggestions.sh"
fi

# ✅ Syntax Highlighting (for Bash)
if [ -f "/usr/share/bash-syntax-highlighting/bash-syntax-highlighting.sh" ]; then
  source "/usr/share/bash-syntax-highlighting/bash-syntax-highlighting.sh"
fi

# ✅ Enable History Search with Arrow Keys
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ✅ Set default editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

# Add more Bash-specific enhancements
# Enable bash-completion if available
if [[ -f "$HOMEBREW_PREFIX/etc/bash_completion" ]]; then
  source "$HOMEBREW_PREFIX/etc/bash_completion"
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Enhanced history settings
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Better directory navigation
shopt -s autocd
shopt -s dirspell
shopt -s cdspell

# Enable magic-enter functionality
# Shows directory listing and git status when pressing Enter on empty line
magic_enter_cmd() {
  if [[ -z "$READLINE_LINE" ]]; then
    echo ""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "$(eza --icons=always -la)"
      echo ""
      echo "$(git status -u .)"
    else
      echo "$(eza --icons=always -la)"
    fi
    echo ""
    READLINE_LINE=""
    READLINE_POINT=0
    return 0
  fi
  return 1
}

bind -x '"\C-m": "magic_enter_cmd || bash_enter_cmd"'
bash_enter_cmd() {
  if [[ $magic_enter_cmd_rv -eq 1 ]]; then
    echo
  fi
}

# Initialize starship prompt - REMOVE THIS LINE
# eval "$(starship init bash)"

# Initialize Spaceship prompt (if not already added by the install script)
if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
  eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
