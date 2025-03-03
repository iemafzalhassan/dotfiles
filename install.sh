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
echo -e "💻 Default Shell: $SHELL"

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

# Request sudo access
echo -e "\n🔑 Requesting sudo access..."
sudo -v

# Install Homebrew only if necessary (for Mac and Linux without a reliable package manager)
if [[ "$OS_TYPE" == "Mac" ]]; then
    if ! command -v brew &>/dev/null; then
        echo -e "\n🍺 Homebrew is not installed. Installing now..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$OS_TYPE" == "Linux" && -z "$PKG_MANAGER" ]]; then
    if ! command -v brew &>/dev/null; then
        echo -e "\n🍺 No suitable package manager detected. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Install Oh My Bash if Bash is detected
if [[ "$SHELL" == *"bash"* ]]; then
    if [[ ! -d "$HOME/.oh-my-bash" ]]; then
        echo -e "\n🎩 Installing Oh My Bash..."
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    fi
fi

# Install Oh My Zsh if Zsh is detected
if [[ "$SHELL" == *"zsh"* ]]; then
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "\n🎩 Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
fi

# Tools to install
tools=( "btop" "tldr" "eza" "zoxide" "fzf" "bat" "ripgrep" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-history-substring-search" "starship" )

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

# Clone dotfiles repository
echo -e "\n🔄 Updating dotfiles repository..."
DOTFILES_REPO="https://github.com/iemafzalhassan/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    git -C "$DOTFILES_DIR" pull
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Link shell configurations
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/config.fish" "$HOME/.config/fish/config.fish"
ln -sf "$DOTFILES_DIR/config.elvish" "$HOME/.config/elvish/rc.elv"

# Configure Starship
if command -v starship &>/dev/null; then
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
fi

# Reload shell configuration
if [[ "$SHELL" == *"bash"* ]]; then
    source "$HOME/.bashrc"
elif [[ "$SHELL" == *"zsh"* ]]; then
    source "$HOME/.zshrc"
elif [[ "$SHELL" == *"fish"* ]]; then
    source "$HOME/.config/fish/config.fish"
elif [[ "$SHELL" == *"elvish"* ]]; then
    source "$HOME/.config/elvish/rc.elv"
fi

echo -e "\n✅ Setup completed successfully!"

