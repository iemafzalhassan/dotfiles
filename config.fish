# Fish shell configuration

# Set locale settings
set -gx LANG "en_GB.UTF-8"
set -gx LC_ALL "en_GB.UTF-8"

# Set editor
set -gx EDITOR vim

# Load Homebrew paths based on architecture
if test (uname -m) = "arm64"
    set -gx HOMEBREW_PREFIX "/opt/homebrew"
else
    set -gx HOMEBREW_PREFIX "/usr/local"
end

# Add Homebrew to PATH
fish_add_path $HOMEBREW_PREFIX/bin

# Load common aliases and functions
if test -f $HOME/.dotfiles/shell/common.sh
    source $HOME/.dotfiles/shell/common.sh
end

# Fish-specific aliases
alias ls="eza --icons=always"
alias cd="z"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"

# Enhanced Fish features
# Enable Fish history search
bind \cr history-pager
bind \e\[A history-search-backward
bind \e\[B history-search-forward

# Enable Fish autosuggestions (built-in)
set -g fish_color_autosuggestion 555

# Enable Fish syntax highlighting (built-in)
set -g fish_color_command 005fd7

# Initialize Fisher plugin manager if available
if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    # Install useful Fisher plugins
    fisher install PatrickF1/fzf.fish
    fisher install jethrokuan/z
    fisher install edc/bass
    fisher install franciscolourenco/done
    fisher install spaceship-prompt/spaceship-prompt
end

# Initialize zoxide
if type -q zoxide
    zoxide init fish | source
end

# Comment out Starship initialization
# if type -q starship
#     starship init fish | source
# end

# Enable magic-enter functionality
# Shows directory listing and git status when pressing Enter on empty line
function fish_user_key_bindings
  bind \r magic_enter
end

function magic_enter
  set -l cmd (commandline)
  if test -z "$cmd"
    echo ""
    if git rev-parse --is-inside-work-tree &>/dev/null
      eza --icons=always -la
      echo ""
      git status -u .
    else
      eza --icons=always -la
    end
    echo ""
    commandline -f execute
  else
    commandline -f execute
  end
end