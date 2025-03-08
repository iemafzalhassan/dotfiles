#!/bin/bash

# Detect Operating System
OS="$(uname -s)"
case "$OS" in
    Linux*)  OS_TYPE=Linux;;
    Darwin*) OS_TYPE=Mac;;
    *)       OS_TYPE="UNKNOWN";;
esac

echo -e "🔍 Detecting system..."
echo -e "🖥️  Operating System: $OS_TYPE"
echo -e "💻 Current Shell: $SHELL"

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
    PKG_MANAGER="brew"
fi

echo -e "📦 Detected package manager: $PKG_MANAGER"

# Ask user which shell they want to use as default
echo -e "\n🐚 Shell Selection"
echo -e "Which shell would you like to use as your default?"
echo -e "1) Zsh (recommended)"
echo -e "2) Bash"
echo -e "3) Fish"
echo -e "4) Elvish"
echo -e "5) Keep current shell ($SHELL)"

read -p "Enter your choice (1-5): " shell_choice

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
        echo -e "Keeping current shell: $SELECTED_SHELL"
        ;;
esac

# Check if the selected shell is installed, if not install it
if ! command -v "$SELECTED_SHELL" &>/dev/null; then
    echo -e "\n🔄 Installing $SELECTED_SHELL shell..."
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
    echo -e "\n🔄 Setting $SELECTED_SHELL as your default shell..."
    if [[ "$OS_TYPE" == "Mac" ]]; then
        # macOS requires special handling
        sudo chsh -s "$SHELL_PATH" "$(whoami)"
    else
        # Linux
        chsh -s "$SHELL_PATH"
    fi
    echo -e "✅ Default shell changed to $SELECTED_SHELL. Changes will take effect after you log out and back in."
fi

# Request sudo access
echo -e "\n🔑 Requesting sudo access..."
sudo -v

# Improve Homebrew installation for all Unix/Linux systems
if [[ "$OS_TYPE" == "Mac" ]]; then
    if ! command -v brew &>/dev/null; then
        echo -e "\n🍺 Homebrew is not installed. Installing now..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Ensure Homebrew is in PATH for Apple Silicon or Intel Macs
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if ! command -v brew &>/dev/null; then
        echo -e "\n🍺 Installing Homebrew for Linux..."
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
    fi
fi

# Install shell frameworks based on selected shell
if [[ "$SELECTED_SHELL" == "bash" ]]; then
    if [[ ! -d "$HOME/.oh-my-bash" ]]; then
        echo -e "\n🎩 Installing Oh My Bash..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" "" --unattended
    fi
elif [[ "$SELECTED_SHELL" == "zsh" ]]; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "\n🎩 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
elif [[ "$SELECTED_SHELL" == "fish" ]]; then
    if ! command -v omf &>/dev/null; then
        echo -e "\n🎩 Installing Oh My Fish..."
        curl -L https://get.oh-my.fish | fish
    fi
fi

# Tools to install - common tools for all shells
tools=( 
    "btop" "tldr" "eza" "zoxide" "fzf" "bat" "ripgrep" "jq" "fd" 
    "ncdu" "htop" "neofetch" "tmux" "tree" "wget" "curl" "git-delta"
)

# Add Nerd Fonts installation section
echo -e "\n🔤 Installing MesloLGS Nerd Font..."
if [[ "$OS_TYPE" == "Mac" ]]; then
    if ! brew list --cask font-meslo-lg-nerd-font &>/dev/null; then
        echo -e "Installing MesloLGS Nerd Font via Homebrew..."
        brew tap homebrew/cask-fonts
        brew install --cask font-meslo-lg-nerd-font
        echo "✅ Installed MesloLGS Nerd Font"
    else
        echo "✅ MesloLGS Nerd Font already installed"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Create fonts directory if it doesn't exist
    mkdir -p "$HOME/.local/share/fonts"
    
    # Download and install Meslo Nerd Font
    echo "Downloading MesloLGS Nerd Font..."
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip"
    FONT_ZIP="/tmp/Meslo.zip"
    
    # Download the font
    curl -L -o "$FONT_ZIP" "$FONT_URL"
    
    # Extract to fonts directory
    unzip -o "$FONT_ZIP" -d "$HOME/.local/share/fonts/MesloLGS" 
    
    # Update font cache
    if command -v fc-cache &>/dev/null; then
        echo "Updating font cache..."
        fc-cache -fv
    fi
    
    echo "✅ Installed MesloLGS Nerd Font"
    echo "NOTE: You may need to configure your terminal to use 'MesloLGS NF' font"
fi

# Add shell-specific tools based on selected shell
SHELL_TYPE="$SELECTED_SHELL"
echo -e "\n🔍 Setting up $SHELL_TYPE environment..."

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
        if [[ ! -f "$DOTFILES_DIR/.zshrc" ]]; then
            echo "Creating .zshrc in dotfiles directory..."
            cp "$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/.zshrc" 2>/dev/null || 
            cp "/Users/v1p3r/Developer/homeLab_setup/dotfiles/.zshrc" "$DOTFILES_DIR/.zshrc" 2>/dev/null ||
            {
                # Create a basic .zshrc if it doesn't exist
                echo "# Basic .zshrc created by install.sh" > "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Set locale settings" >> "$DOTFILES_DIR/.zshrc"
                echo "export LANG=\"en_GB.UTF-8\"" >> "$DOTFILES_DIR/.zshrc"
                echo "export LC_ALL=\"en_GB.UTF-8\"" >> "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Oh My Zsh installation path" >> "$DOTFILES_DIR/.zshrc"
                echo "export ZSH=\"\$HOME/.oh-my-zsh\"" >> "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Set ZSH theme" >> "$DOTFILES_DIR/.zshrc"
                echo "ZSH_THEME=\"spaceship\"" >> "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Load Oh My Zsh" >> "$DOTFILES_DIR/.zshrc"
                echo "source \$ZSH/oh-my-zsh.sh" >> "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Load common aliases and functions" >> "$DOTFILES_DIR/.zshrc"
                echo "if [[ -f \"\$HOME/.dotfiles/shell/common.sh\" ]]; then" >> "$DOTFILES_DIR/.zshrc"
                echo "  source \"\$HOME/.dotfiles/shell/common.sh\"" >> "$DOTFILES_DIR/.zshrc"
                echo "fi" >> "$DOTFILES_DIR/.zshrc"
                echo "" >> "$DOTFILES_DIR/.zshrc"
                echo "# Load Spaceship configuration if available" >> "$DOTFILES_DIR/.zshrc"
                echo "[[ -f \"\$HOME/.spaceshiprc.zsh\" ]] && source \"\$HOME/.spaceshiprc.zsh\"" >> "$DOTFILES_DIR/.zshrc"
            }
        fi
        
        # Now create the symlink
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        
        # Install Oh My Zsh if not already installed
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
            echo -e "\n🎩 Installing Oh My Zsh..."
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        ;;
    "bash")
        ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
        # Install Oh My Bash if not already installed
        if [[ ! -d "$HOME/.oh-my-bash" ]]; then
            echo -e "\n🎩 Installing Oh My Bash..."
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" "" --unattended
        fi
        ;;
    "fish")
        ln -sf "$DOTFILES_DIR/config.fish" "$HOME/.config/fish/config.fish"
        # Install Oh My Fish if not already installed
        if ! command -v omf &>/dev/null; then
            echo -e "\n🎩 Installing Oh My Fish..."
            curl -L https://get.oh-my.fish | fish
        fi
        ;;
    "elvish")
        ln -sf "$DOTFILES_DIR/config.elvish" "$HOME/.config/elvish/rc.elv"
        ;;
esac

# Configure Starship only if it's installed
# Remove or comment out the Starship configuration section
# if command -v starship &>/dev/null; then
#     mkdir -p "$HOME/.config"
#     ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
#     echo "✅ Configured Starship prompt"
# fi

# Install Spaceship prompt based on shell type
echo -e "\n🚀 Installing Spaceship prompt for $SHELL_TYPE shell..."
case "$SHELL_TYPE" in
    "zsh")
        # Install Spaceship for Zsh
        if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" ]]; then
            git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
            ln -sf "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
            
            # Update .zshrc to use Spaceship theme if it exists
            if [[ -f "$HOME/.zshrc" ]]; then
                sed -i.bak 's/ZSH_THEME=".*"/ZSH_THEME="spaceship"/g' "$HOME/.zshrc" || echo "Failed to update ZSH_THEME"
                # Remove Starship initialization if present
                sed -i.bak '/starship init zsh/d' "$HOME/.zshrc" || echo "Failed to remove starship init"
            fi
            
            # Link spaceship config
            ln -sf "$DOTFILES_DIR/.spaceshiprc.zsh" "$HOME/.spaceshiprc.zsh"
            
            echo "✅ Installed Spaceship prompt for Zsh"
        else
            # Link spaceship config even if already installed
            ln -sf "$DOTFILES_DIR/.spaceshiprc.zsh" "$HOME/.spaceshiprc.zsh"
            echo "✅ Spaceship prompt already installed for Zsh"
        fi
        ;;
    "fish")
        # Install Spaceship for Fish
        if ! fish -c "type -q spaceship_prompt" &>/dev/null; then
            # Install Fisher if not already installed
            if ! command -v fisher &>/dev/null; then
                fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
            fi
            fish -c "fisher install spaceship-prompt/spaceship-prompt"
            # Remove Starship initialization if present
            fish -c "sed -i '/starship init/d' $HOME/.config/fish/config.fish"
            echo "✅ Installed Spaceship prompt for Fish"
        else
            echo "✅ Spaceship prompt already installed for Fish"
        fi
        ;;
    "bash")
        # Install Spaceship for Bash (via compatibility layer)
        if [[ ! -d "$HOME/.bash-spaceship-prompt" ]]; then
            git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.bash-spaceship-prompt" --depth=1
            # Add Spaceship initialization to .bashrc
            if ! grep -q "bash-spaceship-prompt" "$HOME/.bashrc"; then
                echo 'eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"' >> "$HOME/.bashrc"
            fi
            # Remove Starship initialization if present
            sed -i.bak '/starship init bash/d' "$HOME/.bashrc"
            echo "✅ Installed Spaceship prompt for Bash"
        else
            echo "✅ Spaceship prompt already installed for Bash"
        fi
        ;;
    "elvish")
        # Elvish doesn't have official Spaceship support, so we'll use Starship as fallback
        if command -v starship &>/dev/null; then
            mkdir -p "$HOME/.config"
            ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
            echo "✅ Configured Starship prompt for Elvish (Spaceship not supported)"
        else
            echo "⚠️ Installing Starship for Elvish (Spaceship not supported)"
            if [[ "$PKG_MANAGER" == "brew" ]]; then
                brew install starship
            elif [[ "$PKG_MANAGER" == "apt" ]]; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            elif [[ "$PKG_MANAGER" == "dnf" ]]; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            elif [[ "$PKG_MANAGER" == "pacman" ]]; then
                sudo pacman -S --noconfirm starship
            fi
            
            if command -v starship &>/dev/null; then
                mkdir -p "$HOME/.config"
                ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
                echo "✅ Configured Starship prompt for Elvish"
            else
                echo "⚠️ Failed to install Starship for Elvish"
            fi
        fi
        ;;
esac

# Reload the current shell configuration
echo -e "\n🔄 Reloading shell configuration..."
case "$SHELL_TYPE" in
    "zsh")
        source "$HOME/.zshrc" 2>/dev/null || echo "⚠️ Could not reload Zsh configuration"
        ;;
    "bash")
        source "$HOME/.bashrc" 2>/dev/null || echo "⚠️ Could not reload Bash configuration"
        ;;
    "fish")
        source "$HOME/.config/fish/config.fish" 2>/dev/null || echo "⚠️ Could not reload Fish configuration"
        ;;
    "elvish")
        source "$HOME/.config/elvish/rc.elv" 2>/dev/null || echo "⚠️ Could not reload Elvish configuration"
        ;;
esac

echo -e "\n✅ Setup completed successfully for $SHELL_TYPE shell!"
echo -e "🚀 Enjoy your customized terminal experience!"

# Make sure eza is installed and configured
echo -e "\n🎨 Configuring file icons..."
if command -v eza &>/dev/null; then
    echo "✅ eza is installed, configuring icons"
    # Update aliases in common.sh to use eza with icons
    if [[ -f "$DOTFILES_DIR/shell/common.sh" ]]; then
        # Create a new common.sh with eza aliases
        cat > "$DOTFILES_DIR/shell/common.sh" << 'EOL'
#!/bin/bash
# Common shell configuration for all shells
# Created automatically by install.sh

# Aliases
# Replace standard ls commands with eza + icons
alias ls="eza --icons=always"
alias ll="eza -la --icons=always"
alias la="eza -a --icons=always"
alias lt="eza -T --icons=always"
alias lg="eza -la --git --icons=always"

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Magic Enter function - shows ls and git status when pressing Enter on empty line
magic_enter() {
  if [[ -z $BUFFER ]]; then
    echo ""
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "$(eza --icons=always -la)"
      echo ""
      echo "$(git status -u .)"
    else
      echo "$(eza --icons=always -la)"
    fi
    echo ""
    return 0
  fi
  return 1
}
EOL
    fi
else
    echo "⚠️ eza is not installed, installing now..."
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install eza
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        # For Ubuntu/Debian, eza might not be in standard repos
        # Try to install from GitHub release if apt fails
        sudo apt install -y eza 2>/dev/null || {
            echo "Installing eza from GitHub release..."
            EZA_VERSION="0.15.5"
            wget -q https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz -O /tmp/eza.tar.gz
            tar -xf /tmp/eza.tar.gz -C /tmp
            sudo mv /tmp/eza /usr/local/bin/
            sudo chmod +x /usr/local/bin/eza
        }
    elif [[ "$PKG_MANAGER" == "dnf" ]]; then
        sudo dnf install -y eza
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        sudo pacman -S --noconfirm eza
    fi
    
    if command -v eza &>/dev/null; then
        echo "✅ eza installed successfully"
    else
        echo "⚠️ Failed to install eza, falling back to ls"
    fi
fi

# Final cleanup - remove any remaining references to Powerlevel10k and Starship
echo -e "\n🧹 Cleaning up any remaining references to other prompts..."

# Remove Powerlevel10k from Zsh config if present
if [[ -f "$HOME/.zshrc" ]]; then
    sed -i.bak '/powerlevel10k/d' "$HOME/.zshrc"
    sed -i.bak '/p10k.zsh/d' "$HOME/.zshrc"
    # Remove the backup file
    rm -f "$HOME/.zshrc.bak"
fi

# Remove Starship from all shell configs
if [[ -f "$HOME/.zshrc" ]]; then
    sed -i.bak '/starship init/d' "$HOME/.zshrc"
    rm -f "$HOME/.zshrc.bak"
fi

if [[ -f "$HOME/.bashrc" ]]; then
    sed -i.bak '/starship init/d' "$HOME/.bashrc"
    rm -f "$HOME/.bashrc.bak"
fi

if [[ -f "$HOME/.config/fish/config.fish" ]]; then
    sed -i.bak '/starship init/d' "$HOME/.config/fish/config.fish"
    rm -f "$HOME/.config/fish/config.fish.bak"
fi

# Remove Powerlevel10k directory if it exists
if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    echo "Removing Powerlevel10k theme..."
    rm -rf "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Remove Starship config if we're not using Elvish
if [[ "$SHELL_TYPE" != "elvish" ]] && [[ -f "$HOME/.config/starship.toml" ]]; then
    echo "Removing Starship configuration..."
    rm -f "$HOME/.config/starship.toml"
fi

# Ensure Spaceship is properly configured for the selected shell
echo -e "\n🚀 Finalizing Spaceship prompt configuration for $SHELL_TYPE..."

case "$SHELL_TYPE" in
    "zsh")
        # Make sure .spaceshiprc.zsh exists and is linked
        if [[ ! -f "$HOME/.spaceshiprc.zsh" ]]; then
            ln -sf "$DOTFILES_DIR/.spaceshiprc.zsh" "$HOME/.spaceshiprc.zsh"
        fi
        
        # Ensure ZSH_THEME is set to spaceship in .zshrc
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q 'ZSH_THEME="spaceship"' "$HOME/.zshrc"; then
                sed -i.bak 's/ZSH_THEME=".*"/ZSH_THEME="spaceship"/g' "$HOME/.zshrc"
                rm -f "$HOME/.zshrc.bak"
            fi
        fi
        ;;
    "bash")
        # Ensure spaceship-prompt.bash is properly initialized
        if [[ -d "$HOME/.bash-spaceship-prompt" ]]; then
            if ! grep -q 'bash-spaceship-prompt/spaceship-prompt.bash' "$HOME/.bashrc"; then
                echo 'eval "$($HOME/.bash-spaceship-prompt/spaceship-prompt.bash)"' >> "$HOME/.bashrc"
            fi
        fi
        ;;
    "fish")
        # Ensure spaceship is set as the fish_prompt
        if fish -c "type -q spaceship_prompt" &>/dev/null; then
            fish -c "function fish_prompt; spaceship_prompt; end; funcsave fish_prompt"
        fi
        ;;
esac

# Final message with instructions
echo -e "\n✅ Setup completed successfully!"
echo -e "🚀 Your terminal is now configured with Spaceship prompt and MesloLGS NF font."
echo -e "📝 You may need to restart your terminal or log out and back in for all changes to take effect."
echo -e "🎨 Make sure your terminal emulator is configured to use 'MesloLGS NF' font."

# Display a sample of what the prompt should look like
echo -e "\n📊 Your prompt should look similar to this:"
echo -e "\033[32muser\033[0m \033[34m@\033[0m \033[36mhostname\033[0m \033[33mat\033[0m \033[35m12:34:56\033[0m"
echo -e "\033[36m~/Developer/your_dir/dotfiles\033[0m"
echo -e "\033[32m❯❯\033[0m "

exit 0

