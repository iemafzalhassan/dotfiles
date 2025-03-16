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
echo -e "╔══════════════════════════════════════════════════════════╗"
echo -e "║                                                          ║"
echo -e "║   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗  ║"
echo -e "║   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝  ║"
echo -e "║   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗    ║"
echo -e "║   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝    ║"
echo -e "║   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗  ║"
echo -e "║   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝  ║"
echo -e "║                                                          ║"
echo -e "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${CYAN}>> dotfile Setup - Terminal Environment Installer <<${NC}\n"
echo -e "${GREEN}>>   Author: Md. Afzal Hassan Ehsani   <<${NC}\n"

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
                # Remove any existing Homebrew PATH entries to avoid duplicates
                sed -i '/linuxbrew/d' ~/.bashrc
                # Add Homebrew to PATH with proper evaluation
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
                # Source bashrc to make changes effective immediately
                source ~/.bashrc
            elif [[ "$SELECTED_SHELL" == "zsh" ]]; then
                # Remove any existing Homebrew PATH entries to avoid duplicates
                sed -i '/linuxbrew/d' ~/.zshrc
                # Add Homebrew to PATH
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
                # Source zshrc to make changes effective immediately
                source ~/.zshrc
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

# Install the common tools
echo -e "\n${BLUE}[*]${NC} Installing common tools..."
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${CYAN}[+]${NC} Installing $tool..."
        if [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install "$tool"
        elif [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt install -y "$tool"
        elif [[ "$PKG_MANAGER" == "dnf" ]]; then
            sudo dnf install -y "$tool"
        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            sudo pacman -S --noconfirm "$tool"
        fi
    else
        echo -e "${GREEN}[✓]${NC} $tool is already installed"
    fi
done

# After installing common tools, add this verification
echo -e "\n${BLUE}[*]${NC} Verifying tool installation..."
for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo -e "${GREEN}[✓]${NC} $tool is properly installed and in PATH"
    else
        echo -e "${YELLOW}[!]${NC} $tool might not be in PATH. Adding Homebrew bin directory to PATH..."
        # Ensure Homebrew bin is in PATH for the current session
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
        # Check again after PATH update
        if command -v "$tool" &>/dev/null; then
            echo -e "${GREEN}[✓]${NC} $tool is now accessible"
        else
            echo -e "${RED}[✗]${NC} $tool is still not accessible. Please check installation."
        fi
    fi
done

# Define dotfiles directory
DOTFILES_DIR="$(pwd)"

# Add code to copy the appropriate shell configuration file based on selected shell
if [[ "$SHELL_TYPE" == "zsh" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Zsh configuration..."
    
    # Install spaceship prompt if not already installed
    if [[ ! -d "$ZSH/custom/themes/spaceship-prompt" ]]; then
        echo -e "${CYAN}[+]${NC} Installing Spaceship prompt..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH/custom/themes/spaceship-prompt" --depth=1
        ln -sf "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH/custom/themes/spaceship.zsh-theme"
    fi
    
    # Install fast-syntax-highlighting if not already installed
    if [[ ! -d "$HOME/.fast-syntax-highlighting" ]]; then
        echo -e "${CYAN}[+]${NC} Installing fast-syntax-highlighting..."
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$HOME/.fast-syntax-highlighting"
    fi
    
    # Install zsh-defer if not already installed
    if [[ ! -d "$HOME/.zsh-defer" ]]; then
        echo -e "${CYAN}[+]${NC} Installing zsh-defer for faster shell startup..."
        mkdir -p "$HOME/.zsh-defer"
        curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-defer/master/zsh-defer.plugin.zsh > "$HOME/.zsh-defer/zsh-defer.plugin.zsh"
    fi
    
    # Copy .zshrc from dotfiles to home directory
    echo -e "${CYAN}[+]${NC} Copying .zshrc to home directory..."
    cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    
    # Set ZSH_THEME to spaceship in .zshrc if not already set
    if ! grep -q "ZSH_THEME=\"spaceship\"" "$HOME/.zshrc"; then
        sed -i.bak 's/^ZSH_THEME=.*$/ZSH_THEME="spaceship"/' "$HOME/.zshrc" || true
    fi
    
    echo -e "${GREEN}[✓]${NC} Zsh configuration complete!"

elif [[ "$SHELL_TYPE" == "bash" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Bash configuration..."
    
    # Install bash-spaceship-prompt if not already installed
    if [[ ! -d "$HOME/.bash-spaceship-prompt" ]]; then
        echo -e "${CYAN}[+]${NC} Installing Spaceship prompt for Bash..."
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.bash-spaceship-prompt" --depth=1
    fi
    
    # Copy .bashrc from dotfiles to home directory
    echo -e "${CYAN}[+]${NC} Copying .bashrc to home directory..."
    cp "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    
    echo -e "${GREEN}[✓]${NC} Bash configuration complete!"

elif [[ "$SHELL_TYPE" == "fish" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Fish configuration..."
    
    # Create fish config directory if it doesn't exist
    mkdir -p "$HOME/.config/fish"
    
    # Copy config.fish from dotfiles to fish config directory
    echo -e "${CYAN}[+]${NC} Copying config.fish to ~/.config/fish/..."
    cp "$DOTFILES_DIR/config.fish" "$HOME/.config/fish/config.fish"
    
    # Install spaceship prompt for fish if not already installed
    if ! fish -c "functions -q spaceship" &>/dev/null; then
        echo -e "${CYAN}[+]${NC} Installing Spaceship prompt for Fish..."
        fish -c "fisher install spaceship-prompt/spaceship-prompt"
    fi
    
    echo -e "${GREEN}[✓]${NC} Fish configuration complete!"

elif [[ "$SHELL_TYPE" == "elvish" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Elvish configuration..."
    
    # Create elvish config directory if it doesn't exist
    mkdir -p "$HOME/.elvish"
    
    # Copy config.elvish from dotfiles to elvish config directory
    echo -e "${CYAN}[+]${NC} Copying config.elvish to ~/.elvish/rc.elv..."
    cp "$DOTFILES_DIR/config.elvish" "$HOME/.elvish/rc.elv"
    
    # Install starship prompt if not already installed
    if ! command -v starship &>/dev/null; then
        echo -e "${CYAN}[+]${NC} Installing Starship prompt for Elvish..."
        if [[ "$PKG_MANAGER" == "brew" ]]; then
            brew install starship
        else
            curl -sS https://starship.rs/install.sh | sh
        fi
    fi
    
    echo -e "${GREEN}[✓]${NC} Elvish configuration complete!"
fi

# Create common shell directory for shared scripts
mkdir -p "$HOME/.dotfiles/shell"

# Create common.sh with shared aliases and functions
echo -e "\n${BLUE}[*]${NC} Creating common shell configuration..."
cat > "$HOME/.dotfiles/shell/common.sh" << 'EOL'
# Common aliases and functions for all shells

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Better ls with eza if available
if command -v eza &>/dev/null; then
  alias ls="eza --icons=always --group-directories-first"
  alias ll="eza -la --icons=always"
  alias la="eza -a --icons=always"
  alias lt="eza -T --icons=always"
  alias lg="eza -la --git --icons=always"
fi

# Git shortcuts
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph"

# Kubernetes shortcuts
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"

# Terraform shortcuts
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"

# Docker shortcuts
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias di="docker images"

# System shortcuts
alias cls="clear"
alias h="history"
alias path="echo -e ${PATH//:/\\n}"
EOL

echo -e "${GREEN}[✓]${NC} Common shell configuration created!"

# After the shell-specific configuration sections, add this code to copy .spaceshiprc.zsh

# Copy .spaceshiprc.zsh to home directory for consistent prompt styling
if [[ -f "$DOTFILES_DIR/.spaceshiprc.zsh" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Spaceship prompt configuration..."
    cp "$DOTFILES_DIR/.spaceshiprc.zsh" "$HOME/.spaceshiprc.zsh"
    echo -e "${GREEN}[✓]${NC} Spaceship prompt configuration copied to home directory"
else
    echo -e "${YELLOW}[!]${NC} .spaceshiprc.zsh not found in dotfiles directory"
    
    # Create a basic .spaceshiprc.zsh if it doesn't exist
    echo -e "${CYAN}[+]${NC} Creating basic .spaceshiprc.zsh..."
    cat > "$HOME/.spaceshiprc.zsh" << 'EOL'
# Spaceship prompt configuration

# Display time
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR="yellow"
SPACESHIP_TIME_FORMAT="%T"
SPACESHIP_TIME_PREFIX="at "
SPACESHIP_TIME_SUFFIX=" "

# Display username
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR="green"
SPACESHIP_USER_SUFFIX=" "

# Display hostname
SPACESHIP_HOST_SHOW=always
SPACESHIP_HOST_COLOR="blue"
SPACESHIP_HOST_PREFIX="@ "
SPACESHIP_HOST_SUFFIX=" "

# Display current directory
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_TRUNC_REPO=true
SPACESHIP_DIR_COLOR="cyan"

# Customize prompt
SPACESHIP_PROMPT_ORDER=(
  user host dir time
  line_sep char
)

SPACESHIP_CHAR_SYMBOL="❯❯ "
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_FAILURE="red"
EOL
    echo -e "${GREEN}[✓]${NC} Basic .spaceshiprc.zsh created"
fi

# Add a final check to ensure eza is properly configured for colorful ls output
if command -v eza &>/dev/null; then
    echo -e "\n${BLUE}[*]${NC} Setting up colorful file listings with eza..."
    
    # Create a shell-specific configuration for eza aliases
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        if ! grep -q "alias ls=\"eza --icons=always" "$HOME/.zshrc"; then
            echo -e "${CYAN}[+]${NC} Adding eza aliases to .zshrc..."
            cat >> "$HOME/.zshrc" << 'EOL'

# Eza aliases for colorful listings with icons
alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"
EOL
        fi
    elif [[ "$SHELL_TYPE" == "bash" ]]; then
        if ! grep -q "alias ls=\"eza --icons=always" "$HOME/.bashrc"; then
            echo -e "${CYAN}[+]${NC} Adding eza aliases to .bashrc..."
            cat >> "$HOME/.bashrc" << 'EOL'

# Eza aliases for colorful listings with icons
alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"
EOL
        fi
    fi
    
    echo -e "${GREEN}[✓]${NC} Colorful file listings configured"
else
    echo -e "${YELLOW}[!]${NC} eza not installed, colorful file listings not available"
fi

# Add this before the final message
echo -e "\n${YELLOW}[!]${NC} IMPORTANT: To ensure all tools work properly after installation:"
echo -e "   1. Restart your terminal session, or"
echo -e "   2. Run: source ~/.${SELECTED_SHELL}rc"
echo -e "   3. If using a different shell than selected, log out and log back in"

# After the shell-specific configuration sections, add this code to copy .spaceshiprc.zsh

# Copy .spaceshiprc.zsh to home directory for consistent prompt styling
if [[ -f "$DOTFILES_DIR/.spaceshiprc.zsh" ]]; then
    echo -e "\n${BLUE}[*]${NC} Setting up Spaceship prompt configuration..."
    cp "$DOTFILES_DIR/.spaceshiprc.zsh" "$HOME/.spaceshiprc.zsh"
    echo -e "${GREEN}[✓]${NC} Spaceship prompt configuration copied to home directory"
else
    echo -e "${YELLOW}[!]${NC} .spaceshiprc.zsh not found in dotfiles directory"
    
    # Create a basic .spaceshiprc.zsh if it doesn't exist
    echo -e "${CYAN}[+]${NC} Creating basic .spaceshiprc.zsh..."
    cat > "$HOME/.spaceshiprc.zsh" << 'EOL'
# Spaceship prompt configuration

# Display time
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR="yellow"
SPACESHIP_TIME_FORMAT="%T"
SPACESHIP_TIME_PREFIX="at "
SPACESHIP_TIME_SUFFIX=" "

# Display username
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR="green"
SPACESHIP_USER_SUFFIX=" "

# Display hostname
SPACESHIP_HOST_SHOW=always
SPACESHIP_HOST_COLOR="blue"
SPACESHIP_HOST_PREFIX="@ "
SPACESHIP_HOST_SUFFIX=" "

# Display current directory
SPACESHIP_DIR_TRUNC=3
SPACESHIP_DIR_TRUNC_REPO=true
SPACESHIP_DIR_COLOR="cyan"

# Customize prompt
SPACESHIP_PROMPT_ORDER=(
  user host dir time
  line_sep char
)

SPACESHIP_CHAR_SYMBOL="❯❯ "
SPACESHIP_CHAR_COLOR_SUCCESS="green"
SPACESHIP_CHAR_COLOR_FAILURE="red"
EOL
    echo -e "${GREEN}[✓]${NC} Basic .spaceshiprc.zsh created"
fi

# Add a final check to ensure eza is properly configured for colorful ls output
if command -v eza &>/dev/null; then
    echo -e "\n${BLUE}[*]${NC} Setting up colorful file listings with eza..."
    
    # Create a shell-specific configuration for eza aliases
    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        if ! grep -q "alias ls=\"eza --icons=always" "$HOME/.zshrc"; then
            echo -e "${CYAN}[+]${NC} Adding eza aliases to .zshrc..."
            cat >> "$HOME/.zshrc" << 'EOL'

# Eza aliases for colorful listings with icons
alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"
EOL
        fi
    elif [[ "$SHELL_TYPE" == "bash" ]]; then
        if ! grep -q "alias ls=\"eza --icons=always" "$HOME/.bashrc"; then
            echo -e "${CYAN}[+]${NC} Adding eza aliases to .bashrc..."
            cat >> "$HOME/.bashrc" << 'EOL'

# Eza aliases for colorful listings with icons
alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"
EOL
        fi
    fi
    
    echo -e "${GREEN}[✓]${NC} Colorful file listings configured"
else
    echo -e "${YELLOW}[!]${NC} eza not installed, colorful file listings not available"
fi

# Add a final message with instructions
echo -e "\n${GREEN}[✓]${NC} ${BOLD}Setup completed successfully!${NC}"
echo -e "${CYAN}[i]${NC} Your terminal is now configured with ${YELLOW}Spaceship prompt${NC} and ${YELLOW}MesloLGS NF${NC} font."
echo -e "${CYAN}[i]${NC} You may need to restart your terminal or log out and back in for all changes to take effect."
echo -e "${CYAN}[i]${NC} Make sure your terminal emulator is configured to use ${YELLOW}'MesloLGS NF'${NC} font."

# Display a sample of what the prompt should look like
echo -e "\n${BLUE}[*]${NC} ${BOLD}Your prompt should look similar to this:${NC}"
echo -e "${GREEN}user${NC} ${BLUE}@${NC} ${CYAN}hostname${NC} ${YELLOW}at${NC} ${MAGENTA}12:34:56${NC}"
echo -e "${BLUE}~/Developer/homeLab_setup/dotfiles${NC}"
echo -e "${GREEN}❯❯${NC} "
