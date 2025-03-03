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

# ✅ WORKING PLUGINS for Bash
plugins=(
  git
  aws
  docker
  helm
)

# Load Plugins (Only if they exist)
for plugin in "${plugins[@]}"; do
  if [ -f "$OSH/plugins/$plugin/$plugin.plugin.sh" ]; then
    source "$OSH/plugins/$plugin/$plugin.plugin.sh"
  fi
done

# ✅ Aliases
alias ll="ls -alh --color=auto"
alias k="kubectl"
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias vi="vim"

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

# ✅ Use Powerline Font (No Powerline Shell)
export PS1="\[\e[0;36m\]\u@\h \[\e[1;33m\]\w\[\e[0m\] $ "

# ✅ Ensure Powerline Fonts Work (Only for WSL/Linux Terminal)
if command -v fc-list &> /dev/null && fc-list | grep -iq "Powerline"; then
  echo "✔ Powerline fonts detected!"
else
  echo "❌ Powerline fonts missing! Install them for better symbols."
fi

eval "$(starship init bash)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
