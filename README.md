# Dotfiles Setup

This script automates the installation and configuration of essential tools, dotfiles, and shell environments across different Linux distributions and macOS.

## Features
- Detects operating system and package manager
- Installs necessary CLI tools (btop, tldr, eza, fzf, etc.)
- Installs and configures Homebrew if needed
- Sets up Oh My Bash for Bash users
- Sets up Oh My Zsh for Zsh users
- Clones and updates dotfiles from the repository
- Symlinks shell configuration files for Bash, Zsh, Fish, and Elvish
- Configures Starship prompt for supported shells

## Installation
### Prerequisites
Ensure you have Git installed before running the script.

```bash
sudo apt install git -y   # Debian/Ubuntu
sudo dnf install git -y   # Fedora
sudo pacman -S git --noconfirm  # Arch
```

### Running the Script
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/iemafzalhassan/dotfiles/main/setup.sh)
```

## Shell Configuration
- **Bash Users**: Oh My Bash is installed, and `.bashrc` is symlinked.
- **Zsh Users**: Oh My Zsh is installed, and `.zshrc` is symlinked.
- **Fish & Elvish Users**: Configuration files are set up automatically.

## Dotfiles Repository
### The script clones the dotfiles repository from GitHub:
```zsh
git clone https://github.com/iemafzalhassan/dotfiles.git
cd dotfiles
```
### change the permission:
```bash
chmod +x install.sh
```
### install it:
```zsh
./install.sh
```


## Troubleshooting
If the installation fails:
- Ensure you have Git installed
- Verify network connectivity
- Run the script as a regular user, not as root

## Contributing
Feel free to submit pull requests or suggest improvements!

## License
MIT License


