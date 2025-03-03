# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set locale settings
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# Dynamic Homebrew path for Intel & Apple Silicon Macs
if [[ $(uname -m) == "arm64" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
else
  export HOMEBREW_PREFIX="/usr/local"
fi

# Oh My Zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Plugins
plugins=(
  git ansible asdf aws brew bun colored-man-pages colorize command-not-found cp
  copypath copyfile docker docker-compose golang helm heroku history iterm2 istioctl
  kops kubectl kubectx minikube node nvm gh git-prompt github magic-enter themes
  tldr extract encode64
)

# Load Oh My Zsh plugins
source $ZSH/oh-my-zsh.sh

# Preferred editor
export EDITOR='vim'

# Aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias cd="z"
alias ls="eza --icons=always"

# Enable zoxide for smarter navigation
eval "$(zoxide init zsh)"

# Enable autosuggestions
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Enable syntax highlighting (should be loaded last)
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Enable history substring search
source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Better command search with arrow keys
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^R' history-incremental-search-backward

# Terraform shortcuts
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias tfa="terraform apply"

# Set default editor based on SSH session
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

# Load Powerlevel10k if installed
if [[ -f "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
