#!/bin/bash

# Terminal colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# ASCII Art Banner
echo -e "${GREEN}"
echo -e "╔═══════════════════════════════════════════════════════════╗"
echo -e "║                                                           ║"
echo -e "║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗  ║"
echo -e "║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝  ║"
echo -e "║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗    ║"
echo -e "║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝    ║"
echo -e "║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗  ║"
echo -e "║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝  ║"
echo -e "║                                                           ║"
echo -e "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${CYAN}>> dotfile Setup - Terminal Environment Installer <<${NC}\n"
echo -e "${RED}>>    Author: Md. Afzal Hassan Ehsani <<${NC}\n"

# Detect Operating System
OS="$(uname -s)"
case "$OS" in
    Linux*)  OS_TYPE=Linux;;
    Darwin*) OS_TYPE=Mac;;
    *)       OS_TYPE="UNKNOWN";;
esac

echo -e "${BLUE}[*]${NC} ${BOLD}System Detection${NC}"
echo -e "${CYAN}[+]${NC} Operating System: ${YELLOW}$OS_TYPE${NC}"
echo -e "${CYAN}[+]${NC} Current Shell: ${YELLOW}$SHELL${NC}"

# Detect package manager
if [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
    fi
elif [[ "$OS_TYPE" == "Mac" ]]; then
    if command -v brew &>/dev/null; then
        PKG_MANAGER="brew"
    else
        PKG_MANAGER="none"
    fi
fi

echo -e "${CYAN}[+]${NC} Package Manager: ${YELLOW}$PKG_MANAGER${NC}\n"

# Ask user which shell they want to use as default
echo -e "${BLUE}[*]${NC} ${BOLD}Shell Selection${NC}"
echo -e "${DIM}Which shell would you like to use as your default?${NC}"
echo -e "${CYAN}[1]${NC} Zsh ${GREEN}(recommended)${NC}"
echo -e "${CYAN}[2]${NC} Bash"
echo -e "${CYAN}[3]${NC} Fish"
echo -e "${CYAN}[4]${NC} Elvish"
echo -e "${CYAN}[5]${NC} Keep current shell (${YELLOW}$SHELL${NC})"

read -p "$(echo -e "${YELLOW}>>>${NC} Enter your choice [1-5]: ")" shell_choice

case $shell_choice in
    1)
        SELECTED_SHELL="zsh"
        SHELL_PATH=$(which zsh 2>/dev/null || echo "/bin/zsh")
        ;;
    2)
        SELECTED_SHELL="bash"
        SHELL_PATH=$(which bash 2>/dev/null || echo "/bin/bash")
        ;;
    3)
        SELECTED_SHELL="fish"
        SHELL_PATH=$(which fish 2>/dev/null || echo "/usr/bin/fish")
        ;;
    4)
        SELECTED_SHELL="elvish"
        SHELL_PATH=$(which elvish 2>/dev/null || echo "/usr/bin/elvish")
        ;;
    5|*)
        SELECTED_SHELL=$(basename "$SHELL")
        SHELL_PATH="$SHELL"
        echo -e "${CYAN}[i]${NC} Keeping current shell: ${YELLOW}$SELECTED_SHELL${NC}"
        ;;
esac

# Check if the selected shell is installed, if not install it
if ! command -v "$SELECTED_SHELL" &>/dev/null; then
    echo -e "\n${BLUE}[*]${NC} Installing ${YELLOW}$SELECTED_SHELL${NC} shell..."
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install "$SELECTED_SHELL"
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt install -y "$SELECTED_SHELL"
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y "$SELECTED_SHELL"
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        sudo pacman -S --noconfirm "$SELECTED_SHELL"
    fi
fi

# Set the selected shell as default
if [[ "$SHELL" != "$SHELL_PATH" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting ${YELLOW}$SELECTED_SHELL${NC} as your default shell..."
    if [[ "$OS_TYPE" == "Mac" ]]; then
        # macOS requires special handling
        sudo chsh -s "$SHELL_PATH" "$(whoami)"
    else
        # Linux
        chsh -s "$SHELL_PATH"
    fi
    echo -e "${GREEN}[✓]${NC} Default shell changed to ${YELLOW}$SELECTED_SHELL${NC}. Changes will take effect after you log out and back in."
fi

# Request sudo access
echo -e "\n${BLUE}[*]${NC} Requesting sudo access..."
sudo -v

# Ask if user wants to install Homebrew
if ! command -v brew &>/dev/null; then
    echo -e "\n${BLUE}[*]${NC} ${BOLD}Homebrew Installation${NC}"
    echo -e "${DIM}Homebrew is a package manager that simplifies installing software on macOS and Linux.${NC}"
    read -p "$(echo -e "${YELLOW}>>>${NC} Do you want to install Homebrew? [y/N]: ")" install_homebrew
    
    if [[ "$install_homebrew" =~ ^[Yy]$ ]]; then
        echo -e "\n${BLUE}[*]${NC} Installing Homebrew..."
        if [[ "$OS_TYPE" == "Mac" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Ensure Homebrew is in PATH for Apple Silicon or Intel Macs
            if [[ $(uname -m) == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            PKG_MANAGER="brew"
        elif [[ "$OS_TYPE" == "Linux" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Add Homebrew to PATH for the current session
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
            
            # Add Homebrew to the appropriate shell config for persistence
            if [[ "$SELECTED_SHELL" == "bash" ]]; then
                grep -q "brew shellenv" ~/.bashrc || echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            elif [[ "$SELECTED_SHELL" == "zsh" ]]; then
                grep -q "brew shellenv" ~/.zshrc || echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
            elif [[ "$SELECTED_SHELL" == "fish" ]]; then
                mkdir -p ~/.config/fish/conf.d
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > ~/.config/fish/conf.d/homebrew.fish
            fi
            PKG_MANAGER="brew"
        fi
        echo -e "${GREEN}[✓]${NC} Homebrew installed successfully"
    else
        echo -e "${YELLOW}[!]${NC} Skipping Homebrew installation"
        # If Homebrew is not installed and user doesn't want to install it, set PKG_MANAGER to a fallback
        if [[ "$OS_TYPE" == "Mac" ]]; then
            echo -e "${YELLOW}[!]${NC} Warning: Some tools may not be installed without Homebrew on macOS"
            PKG_MANAGER="none"
        fi
    fi
else
    echo -e "\n${GREEN}[✓]${NC} Homebrew is already installed"
    if [[ "$OS_TYPE" == "Mac" ]]; then
        # Ensure Homebrew is in PATH for Apple Silicon or Intel Macs
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    PKG_MANAGER="brew"
fi

# Install shell frameworks based on selected shell
if [[ "$SELECTED_SHELL" == "bash" ]]; then
    if [[ ! -d "$HOME/.oh-my-bash" ]]; then
        echo -e "\n${BLUE}[*]${NC} Installing Oh My Bash..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" "" --unattended
    fi
elif [[ "$SELECTED_SHELL" == "zsh" ]]; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "\n${BLUE}[*]${NC} Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
elif [[ "$SELECTED_SHELL" == "fish" ]]; then
    if ! command -v omf &>/dev/null; then
        echo -e "\n${BLUE}[*]${NC} Installing Oh My Fish..."
        curl -L https://get.oh-my.fish | fish
    fi
fi

# Tools to install - common tools for all shells
tools=( 
    "btop" "tldr" "eza" "zoxide" "fzf" "bat" "ripgrep" "jq" "fd" 
    "ncdu" "htop" "neofetch" "tmux" "tree" "wget" "curl" "git-delta"
)

# Add Nerd Fonts installation section
echo -e "\n${BLUE}[*]${NC} Installing MesloLGS Nerd Font..."
if [[ "$OS_TYPE" == "Mac" && "$PKG_MANAGER" == "brew" ]]; then
    if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
        echo -e "${CYAN}[+]${NC} Installing MesloLGS Nerd Font via Homebrew..."
        brew tap homebrew/cask-fonts
        brew install --cask font-meslo-lg-nerd-font
        echo -e "${GREEN}[✓]${NC} Installed MesloLGS Nerd Font"
    else
        echo -e "${GREEN}[✓]${NC} MesloLGS Nerd Font already installed"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Create fonts directory if it doesn't exist
    mkdir -p "$HOME/.local/share/fonts"
    
    # Download and install Meslo Nerd Font
    echo -e "${CYAN}[+]${NC} Downloading MesloLGS Nerd Font..."
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip"
    FONT_ZIP="/tmp/Meslo.zip"
    
    # Download the font
    curl -L -o "$FONT_ZIP" "$FONT_URL"
    
    # Extract to fonts directory
    unzip -o "$FONT_ZIP" -d "$HOME/.local/share/fonts/MesloLGS" 
    
    # Update font cache
    if command -v fc-cache &>/dev/null; then
        echo -e "${CYAN}[+]${NC} Updating font cache..."
        fc-cache -fv
    fi
    
    echo -e "${GREEN}[✓]${NC} Installed MesloLGS Nerd Font"
    echo -e "${YELLOW}[!]${NC} NOTE: You may need to configure your terminal to use 'MesloLGS NF' font"
elif [[ "$OS_TYPE" == "Mac" && "$PKG_MANAGER" == "none" ]]; then
    echo -e "${YELLOW}[!]${NC} Skipping MesloLGS Nerd Font installation (requires Homebrew)"
    echo -e "${YELLOW}[!]${NC} Please install manually from: https://github.com/ryanoasis/nerd-fonts/releases"
fi

# Add shell-specific tools based on selected shell
SHELL_TYPE="$SELECTED_SHELL"
echo -e "\n${BLUE}[*]${NC} Setting up ${YELLOW}$SHELL_TYPE${NC} environment..."

if [[ "$SHELL_TYPE" == "zsh" ]]; then
    tools+=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-history-substring-search")
elif [[ "$SHELL_TYPE" == "bash" ]]; then
    # Add Bash-specific tools to match Zsh functionality
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        tools+=("bash-completion@2" "bash-git-prompt")
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt install -y bash-completion bash-git-prompt
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y bash-completion bash-git-prompt
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        sudo pacman -S --noconfirm bash-completion bash-git-prompt
    fi
elif [[ "$SHELL_TYPE" == "fish" ]]; then
    # Fish has many features built-in, but we'll add Fisher plugin manager
    if ! fish -c "functions -q fisher" &>/dev/null; then
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
        # Install useful Fisher plugins
        fish -c "fisher install PatrickF1/fzf.fish"
        fish -c "fisher install jethrokuan/z"
        fish -c "fisher install edc/bass"
        fish -c "fisher install franciscolourenco/done"
    fi
fi

echo -e "\n🛠️  Installing selected tools..."
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        if [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install "$tool"
        elif [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install -y "$tool"
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            sudo dnf install -y "$tool"
        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            sudo pacman -S --noconfirm "$tool"
        fi
        
        if command -v "$tool" &>/dev/null; then
            echo "✔️  Installed $tool successfully."
        else
            echo "⚠️  Failed to install $tool."
        fi
    else
        echo "✅ $tool is already installed. Skipping..."
    fi
done

# Create necessary directories only for the selected shell
mkdir -p "$HOME/.dotfiles/shell"
case "$SHELL_TYPE" in
    "zsh")
        # Only create Zsh-specific directories
        ;;
    "bash")
        # Only create Bash-specific directories
        ;;
    "fish")
        mkdir -p "$HOME/.config/fish"
        ;;
    "elvish")
        mkdir -p "$HOME/.config/elvish"
        ;;
esac

# Clone dotfiles repository
echo -e "\n🔄 Updating dotfiles repository..."
DOTFILES_REPO="https://github.com/iemafzalhassan/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Check if we're already in the dotfiles directory
if [[ "$(pwd)" == *"dotfiles"* ]]; then
    # We're already in the dotfiles directory, copy to ~/.dotfiles
    echo "Copying current directory to $DOTFILES_DIR..."
    mkdir -p "$DOTFILES_DIR"
    cp -R ./* "$DOTFILES_DIR/"
    cp -R ./.* "$DOTFILES_DIR/" 2>/dev/null || true  # Copy hidden files too
elif [[ -d "$DOTFILES_DIR" ]]; then
    git -C "$DOTFILES_DIR" pull || echo "Not a git repository, skipping pull"
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || 
    echo "Failed to clone repository, copying local files instead" &&
    mkdir -p "$DOTFILES_DIR" &&
    cp -R ./* "$DOTFILES_DIR/" &&
    cp -R ./.* "$DOTFILES_DIR/" 2>/dev/null || true
fi

# Create shell directory if it doesn't exist
mkdir -p "$DOTFILES_DIR/shell"

# Copy common.sh to the shell directory if it doesn't exist
if [[ ! -f "$DOTFILES_DIR/shell/common.sh" ]]; then
    if [[ -f "./shell/common.sh" ]]; then
        cp "./shell/common.sh" "$DOTFILES_DIR/shell/common.sh"
    elif [[ -f "./common.sh" ]]; then
        cp "./common.sh" "$DOTFILES_DIR/shell/common.sh"
    else
        # Create a basic common.sh if it doesn't exist
        echo "#!/bin/bash" > "$DOTFILES_DIR/shell/common.sh"
        echo "# Common shell configuration for all shells" >> "$DOTFILES_DIR/shell/common.sh"
        echo "# Created automatically by install.sh" >> "$DOTFILES_DIR/shell/common.sh"
        echo "" >> "$DOTFILES_DIR/shell/common.sh"
        echo "# Aliases" >> "$DOTFILES_DIR/shell/common.sh"
        echo "alias ll=\"ls -alh\"" >> "$DOTFILES_DIR/shell/common.sh"
        echo "alias la=\"ls -A\"" >> "$DOTFILES_DIR/shell/common.sh"
        echo "alias l=\"ls\"" >> "$DOTFILES_DIR/shell/common.sh"
    fi
fi

# Link only the shell configuration for the detected shell
echo -e "\n🔗 Linking configuration files for $SHELL_TYPE shell..."
case "$SHELL_TYPE" in
    "zsh")
        # Make sure .zshrc exists in the dotfiles directory
        # Create a basic .spaceshiprc.zsh if it doesn't exist
        if [[ ! -f "$DOTFILES_DIR/.spaceshiprc.zsh" ]]; then
        echo "Creating .spaceshiprc.zsh in dotfiles directory..."
        cat > "$DOTFILES_DIR/.spaceshiprc.zsh" << 'EOL'
        # Spaceship ZSH Configuration
        
        # Display time
        SPACESHIP_TIME_SHOW=true
        SPACESHIP_TIME_COLOR="yellow"
        SPACESHIP_TIME_FORMAT="%T"
        
        # Display username always
        SPACESHIP_USER_SHOW=always
        SPACESHIP_USER_COLOR="green"
        
        # Display hostname always
        SPACESHIP_HOST_SHOW=always
        SPACESHIP_HOST_COLOR="cyan"
        
        # Display current directory
        SPACESHIP_DIR_TRUNC=0
        SPACESHIP_DIR_TRUNC_REPO=false
        SPACESHIP_DIR_COLOR="blue"
        
        # Git settings
        SPACESHIP_GIT_SHOW=true
        SPACESHIP_GIT_PREFIX="on "
        SPACESHIP_GIT_SUFFIX=""
        SPACESHIP_GIT_BRANCH_COLOR="magenta"
        SPACESHIP_GIT_STATUS_COLOR="red"
        
        # Customize prompt
        SPACESHIP_PROMPT_ADD_NEWLINE=true
        SPACESHIP_PROMPT_SEPARATE_LINE=true
        SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false
        SPACESHIP_PROMPT_PREFIXES_SHOW=true
        SPACESHIP_PROMPT_SUFFIXES_SHOW=true
        SPACESHIP_PROMPT_DEFAULT_PREFIX="via "
        SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "
        
        # Customize prompt order
        SPACESHIP_PROMPT_ORDER=(
        time          # Time stamps section
        user          # Username section
        host          # Hostname section
        dir           # Current directory section
        git           # Git section (git_branch + git_status)
        package       # Package version
        node          # Node.js section
        ruby          # Ruby section
        python        # Python section
        golang        # Go section
        docker        # Docker section
        line_sep      # Line break
        char          # Prompt character
        )
        
        # Customize right prompt
        SPACESHIP_RPROMPT_ORDER=(
        exec_time     # Execution time
        jobs          # Background jobs indicator
        exit_code     # Exit code section
        )
        EOL
        fi
        
        # Create a basic starship.toml for Elvish if it doesn't exist
        if [[ "$SHELL_TYPE" == "elvish" ]] && [[ ! -f "$DOTFILES_DIR/starship.toml" ]]; then
        echo "Creating starship.toml for Elvish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/starship.toml" << 'EOL'
        # Starship Configuration for Elvish
        
        # Get editor completions based on the config schema
        "$schema" = 'https://starship.rs/config-schema.json'
        
        # Inserts a blank line between shell prompts
        add_newline = true
        
        # Replace the "❯" symbol in the prompt with "➜"
        [character]
        success_symbol = "[➜](bold green)"
        error_symbol = "[✗](bold red)"
        
        # Disable the package module, hiding it from the prompt completely
        [package]
        disabled = true
        
        # Display time
        [time]
        disabled = false
        format = '[$time]($style) '
        time_format = "%T"
        style = "yellow"
        
        # Display username always
        [username]
        style_user = "green"
        style_root = "red"
        format = "[$user]($style) "
        disabled = false
        show_always = true
        
        # Display hostname always
        [hostname]
        ssh_only = false
        format = "[@$hostname]($style) "
        style = "cyan"
        disabled = false
        
        # Display current directory
        [directory]
        truncation_length = 0
        truncate_to_repo = false
        style = "blue"
        
        # Git settings
        [git_branch]
        format = "on [$symbol$branch]($style) "
        style = "magenta"
        
        [git_status]
        style = "red"
        EOL
        fi
        
        # Create a basic config.fish if it doesn't exist
        if [[ "$SHELL_TYPE" == "fish" ]] && [[ ! -f "$DOTFILES_DIR/config.fish" ]]; then
        echo "Creating config.fish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.fish" << 'EOL'
        # Fish shell configuration
        
        # Set locale settings
        set -x LANG "en_GB.UTF-8"
        set -x LC_ALL "en_GB.UTF-8"
        
        # Load common aliases and functions
        if test -f "$HOME/.dotfiles/shell/common.sh"
        bass source "$HOME/.dotfiles/shell/common.sh"
        end
        
        # Initialize Spaceship prompt
        if type -q spaceship_prompt
        function fish_prompt
        spaceship_prompt
        end
        
        # Use eza instead of ls if available
        if type -q eza
        alias ls="eza --icons=always"
        alias ll="eza -la --icons=always"
        alias la="eza -a --icons=always"
        alias lt="eza -T --icons=always"
        alias lg="eza -la --git --icons=always"
        end
        
        # Navigation shortcuts
        alias ..="cd .."
        alias ...="cd ../.."
        alias ....="cd ../../.."
        EOL
        fi
        
        # Create a basic .bashrc if it doesn't exist
        if [[ "$SHELL_TYPE" == "bash" ]] && [[ ! -f "$DOTFILES_DIR/.bashrc" ]]; then
        echo "Creating .bashrc in dotfiles directory..."
        cat > "$DOTFILES_DIR/.bashrc" << 'EOL'
        # Basic .bashrc created by install.sh
        
        # Set locale settings
        export LANG="en_GB.UTF-8"
        export LC_ALL="en_GB.UTF-8"
        
        # Load common aliases and functions
        if [[ -f "$HOME/.dotfiles/shell/common.sh" ]]; then
        source "$HOME/.dotfiles/shell/common.sh"
        fi
        
        # Load Spaceship prompt if available
        if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
        eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"
        fi
        
        # Enable bash-completion if installed
        if [[ -f /usr/local/etc/bash_completion ]]; then
        source /usr/local/etc/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
        fi
        
        # Enable git-prompt if installed
        if [[ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
        source /usr/local/etc/bash_completion.d/git-prompt.sh
        elif [[ -f /etc/bash_completion.d/git-prompt ]]; then
        source /etc/bash_completion.d/git-prompt
        fi
        
        # History settings
        HISTCONTROL=ignoreboth
        HISTSIZE=1000
        HISTFILESIZE=2000
        shopt -s histappend
        
        # Check window size after each command
        shopt -s checkwinsize
        
        # Make less more friendly for non-text input files
        [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
        
        # Set a fancy prompt
        PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]@\[\033[00m\] \[\033[01;36m\]\h\[\033[00m\] \[\033[01;33m\]\t\[\033[00m\] \[\033[01;35m\]\w\[\033[00m\]\n\[\033[01;32m\]➜\[\033[00m\] '
        EOL
        fi
        
        # Create a basic config.elvish if it doesn't exist
        if [[ "$SHELL_TYPE" == "elvish" ]] && [[ ! -f "$DOTFILES_DIR/config.elvish" ]]; then
        echo "Creating config.elvish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.elvish" << 'EOL'
        # Elvish shell configuration
        
        # Set locale settings
        set-env LANG "en_GB.UTF-8"
        set-env LC_ALL "en_GB.UTF-8"
        
        # Initialize Starship prompt
        eval (starship init elvish)
        
        # Aliases
        fn ls [@a]{ e:eza --icons=always $@a }
        fn ll [@a]{ e:eza -la --icons=always $@a }
        fn la [@a]{ e:eza -a --icons=always $@a }
        fn lt [@a]{ e:eza -T --icons=always $@a }
        fn lg [@a]{ e:eza -la --git --icons=always $@a }
        
        # Navigation shortcuts
        fn .. { cd .. }
        fn ... { cd ../.. }
        fn .... { cd ../../.. }
        EOL
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Create a basic config.fish if it doesn't exist
        if [[ "$SHELL_TYPE" == "fish" ]] && [[ ! -f "$DOTFILES_DIR/config.fish" ]]; then
        echo "Creating config.fish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.fish" << 'EOL'
        # Fish shell configuration
        
        # Set locale settings
        set -x LANG "en_GB.UTF-8"
        set -x LC_ALL "en_GB.UTF-8"
        
        # Load common aliases and functions
        if test -f "$HOME/.dotfiles/shell/common.sh"
        bass source "$HOME/.dotfiles/shell/common.sh"
        end
        
        # Initialize Spaceship prompt
        if type -q spaceship_prompt
        function fish_prompt
        spaceship_prompt
        end
        
        # Use eza instead of ls if available
        if type -q eza
        alias ls="eza --icons=always"
        alias ll="eza -la --icons=always"
        alias la="eza -a --icons=always"
        alias lt="eza -T --icons=always"
        alias lg="eza -la --git --icons=always"
        end
        
        # Navigation shortcuts
        alias ..="cd .."
        alias ...="cd ../.."
        alias ....="cd ../../.."
        EOL
        fi
        
        # Create a basic .bashrc if it doesn't exist
        if [[ "$SHELL_TYPE" == "bash" ]] && [[ ! -f "$DOTFILES_DIR/.bashrc" ]]; then
        echo "Creating .bashrc in dotfiles directory..."
        cat > "$DOTFILES_DIR/.bashrc" << 'EOL'
        # Basic .bashrc created by install.sh
        
        # Set locale settings
        export LANG="en_GB.UTF-8"
        export LC_ALL="en_GB.UTF-8"
        
        # Load common aliases and functions
        if [[ -f "$HOME/.dotfiles/shell/common.sh" ]]; then
        source "$HOME/.dotfiles/shell/common.sh"
        fi
        
        # Load Spaceship prompt if available
        if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
        eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"
        fi
        
        # Enable bash-completion if installed
        if [[ -f /usr/local/etc/bash_completion ]]; then
        source /usr/local/etc/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
        fi
        
        # Enable git-prompt if installed
        if [[ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
        source /usr/local/etc/bash_completion.d/git-prompt.sh
        elif [[ -f /etc/bash_completion.d/git-prompt ]]; then
        source /etc/bash_completion.d/git-prompt
        fi
        
        # History settings
        HISTCONTROL=ignoreboth
        HISTSIZE=1000
        HISTFILESIZE=2000
        shopt -s histappend
        
        # Check window size after each command
        shopt -s checkwinsize
        
        # Make less more friendly for non-text input files
        [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
        
        # Set a fancy prompt
        PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]@\[\033[00m\] \[\033[01;36m\]\h\[\033[00m\] \[\033[01;33m\]\t\[\033[00m\] \[\033[01;35m\]\w\[\033[00m\]\n\[\033[01;32m\]➜\[\033[00m\] '
        EOL
        fi
        
        # Create a basic config.elvish if it doesn't exist
        if [[ "$SHELL_TYPE" == "elvish" ]] && [[ ! -f "$DOTFILES_DIR/config.elvish" ]]; then
        echo "Creating config.elvish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.elvish" << 'EOL'
        # Elvish shell configuration
        
        # Set locale settings
        set-env LANG "en_GB.UTF-8"
        set-env LC_ALL "en_GB.UTF-8"
        
        # Initialize Starship prompt
        eval (starship init elvish)
        
        # Aliases
        fn ls [@a]{ e:eza --icons=always $@a }
        fn ll [@a]{ e:eza -la --icons=always $@a }
        fn la [@a]{ e:eza -a --icons=always $@a }
        fn lt [@a]{ e:eza -T --icons=always $@a }
        fn lg [@a]{ e:eza -la --git --icons=always $@a }
        
        # Navigation shortcuts
        fn .. { cd .. }
        fn ... { cd ../.. }
        fn .... { cd ../../.. }
        EOL
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Create a basic config.fish if it doesn't exist
        if [[ "$SHELL_TYPE" == "fish" ]] && [[ ! -f "$DOTFILES_DIR/config.fish" ]]; then
        echo "Creating config.fish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.fish" << 'EOL'
        # Fish shell configuration
        
        # Set locale settings
        set -x LANG "en_GB.UTF-8"
        set -x LC_ALL "en_GB.UTF-8"
        
        # Load common aliases and functions
        if test -f "$HOME/.dotfiles/shell/common.sh"
        bass source "$HOME/.dotfiles/shell/common.sh"
        end
        
        # Initialize Spaceship prompt
        if type -q spaceship_prompt
        function fish_prompt
        spaceship_prompt
        end
        
        # Use eza instead of ls if available
        if type -q eza
        alias ls="eza --icons=always"
        alias ll="eza -la --icons=always"
        alias la="eza -a --icons=always"
        alias lt="eza -T --icons=always"
        alias lg="eza -la --git --icons=always"
        end
        
        # Navigation shortcuts
        alias ..="cd .."
        alias ...="cd ../.."
        alias ....="cd ../../.."
        EOL
        fi
        
        # Create a basic .bashrc if it doesn't exist
        if [[ "$SHELL_TYPE" == "bash" ]] && [[ ! -f "$DOTFILES_DIR/.bashrc" ]]; then
        echo "Creating .bashrc in dotfiles directory..."
        cat > "$DOTFILES_DIR/.bashrc" << 'EOL'
        # Basic .bashrc created by install.sh
        
        # Set locale settings
        export LANG="en_GB.UTF-8"
        export LC_ALL="en_GB.UTF-8"
        
        # Load common aliases and functions
        if [[ -f "$HOME/.dotfiles/shell/common.sh" ]]; then
        source "$HOME/.dotfiles/shell/common.sh"
        fi
        
        # Load Spaceship prompt if available
        if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
        eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"
        fi
        
        # Enable bash-completion if installed
        if [[ -f /usr/local/etc/bash_completion ]]; then
        source /usr/local/etc/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
        fi
        
        # Enable git-prompt if installed
        if [[ -f /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
        source /usr/local/etc/bash_completion.d/git-prompt.sh
        elif [[ -f /etc/bash_completion.d/git-prompt ]]; then
        source /etc/bash_completion.d/git-prompt
        fi
        
        # History settings
        HISTCONTROL=ignoreboth
        HISTSIZE=1000
        HISTFILESIZE=2000
        shopt -s histappend
        
        # Check window size after each command
        shopt -s checkwinsize
        
        # Make less more friendly for non-text input files
        [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
        
        # Set a fancy prompt
        PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]@\[\033[00m\] \[\033[01;36m\]\h\[\033[00m\] \[\033[01;33m\]\t\[\033[00m\] \[\033[01;35m\]\w\[\033[00m\]\n\[\033[01;32m\]➜\[\033[00m\] '
        EOL
        fi
        
        # Create a basic config.elvish if it doesn't exist
        if [[ "$SHELL_TYPE" == "elvish" ]] && [[ ! -f "$DOTFILES_DIR/config.elvish" ]]; then
        echo "Creating config.elvish in dotfiles directory..."
        mkdir -p "$DOTFILES_DIR"
        cat > "$DOTFILES_DIR/config.elvish" << 'EOL'
        # Elvish shell configuration
        
        # Set locale settings
        set-env LANG "en_GB.UTF-8"
        set-env LC_ALL "en_GB.UTF-8"
        
        # Initialize Starship prompt
        eval (starship init elvish)
        
        # Aliases
        fn ls [@a]{ e:eza --icons=always $@a }
        fn ll [@a]{ e:eza -la --icons=always $@a }
        fn la [@a]{ e:eza -a --icons=always $@a }
        fn lt [@a]{ e:eza -T --icons=always $@a }
        fn lg [@a]{ e:eza -la --git --icons=always $@a }
        
        # Navigation shortcuts
        fn .. { cd .. }
        fn ... { cd ../.. }
        fn .... { cd ../../.. }
        EOL
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")
        if ! grep -q "TERM=" "$HOME/.zshrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.zshrc"
        fi
        ;;
        "bash")
        if ! grep -q "TERM=" "$HOME/.bashrc"; then
        echo 'export TERM="xterm-256color"' >> "$HOME/.bashrc"
        fi
        ;;
        "fish")
        if ! grep -q "TERM=" "$HOME/.config/fish/config.fish"; then
        echo 'set -x TERM "xterm-256color"' >> "$HOME/.config/fish/config.fish"
        fi
        ;;
        esac
        fi
        
        # Create a README.md file with instructions
        echo -e "\n${BLUE}[*]${NC} Creating README.md with usage instructions..."
        cat > "$DOTFILES_DIR/README.md" << 'EOL'
        # Dotfiles
        
        This repository contains my personal dotfiles for various shells and tools.
        
        ## Installation
        
        To install these dotfiles, run:
        
        ```bash
        ./install.sh
        ```
        EOL
        fi
        fi
        fi
        fi
        
        # Add a check for terminal color support
        echo -e "\n${BLUE}[*]${NC} Checking terminal color support..."
        if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "tmux-256color" ]]; then
        echo -e "${GREEN}[✓]${NC} Your terminal supports 256 colors"
        else
        echo -e "${YELLOW}[!]${NC} Your terminal might not support 256 colors"
        echo -e "${YELLOW}[!]${NC} For best experience, set your TERM to xterm-256color"
        
        # Add TERM setting to shell config
        case "$SHELL_TYPE" in
        "zsh")

