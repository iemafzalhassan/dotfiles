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
if [[ -f "$HOME/.dotfiles/shell/common.sh" ]]; then
  source "$HOME/.dotfiles/shell/common.sh"
fi

# Enable magic-enter functionality for Bash
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

# Initialize Spaceship prompt (if not already added by the install script)
if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
  eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
