# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A sophisticated, cross-platform configuration setup for development environments with a strong focus on DevOps workflows. This repository contains customized configurations for Zsh, Neovim, and other development tools that work seamlessly across macOS, Debian-based, Arch-based, and RHEL-based Linux distributions.

---

## 🚀 Quick Start

Get up and running with a single command. This will clone the repository and execute the installation script.

```bash
# Clone the repository
git clone https://github.com/iemafzal/dotfiles.git ~/.dotfiles

# Navigate to the dotfiles directory
cd ~/.dotfiles

# Run the installation script
./install.sh
```

---

## ✨ Features

This setup is designed to be powerful, consistent, and easy to manage across multiple systems.

- **Cross-Platform Consistency**: The same look, feel, and functionality on macOS, Debian, Arch, and RHEL.
- **Automated Installation**: The main script (`install.sh`) handles OS detection, dependency installation, and configuration symlinking.
- **Zsh Powered**: A rich shell experience with Oh My Zsh, Spaceship Prompt, and numerous plugins.
- **Neovim as an IDE**: A full-fledged Neovim setup with LSP, fuzzy finding, Git integration, and more.
- **DevOps Ready**: Packed with aliases, functions, and tools for Kubernetes, Docker, Terraform, and AWS.
- **Modular & Customizable**: Easily extend or modify configurations to fit your personal workflow.

---

## 🛠️ What's Included

### 🐚 Shell Environment (Zsh)

- **Framework**: Oh My Zsh for robust plugin and theme management.
- **Prompt**: Spaceship Prompt for a detailed, context-aware prompt (Git branch, K8s context, etc.).
- **Plugins**: Includes `zsh-syntax-highlighting`, `zsh-autosuggestions`, `fzf`, and more.
- **Navigation**: Directory jumping with `z` and history search with `Ctrl+R`.
- **DevOps Aliases**: Hundreds of aliases for `kubectl`, `docker`, `terraform`, and `aws`.

### 💻 Editor Setup (Neovim)

- **Plugin Manager**: Packer.nvim for declarative and fast plugin management.
- **LSP Integration**: Out-of-the-box support for numerous languages (Python, Go, Rust, TypeScript, Terraform, etc.).
- **UI Enhancements**: Lualine, Bufferline, Nvim-Tree, and Which-Key for a modern editing experience.
- **Fuzzy Finding**: Telescope for finding files, text, buffers, and more.
- **Git Integration**: Fugitive and Gitsigns for seamless Git operations from within Neovim.

---

## 📦 Supported Platforms

The installation script automatically detects your OS and installs the appropriate packages.

| Platform      | Package Manager | Installation Script          |
|---------------|-----------------|------------------------------|
| macOS         | Homebrew        | `packages/macos.sh`          |
| Debian/Ubuntu | APT             | `packages/debian.sh`         |
| Arch Linux    | Pacman / AUR    | `packages/arch.sh`           |
| RHEL/Fedora   | DNF             | `packages/redhat.sh`         |

---

## 🔧 Customization

### Adding Custom Zsh Functions

Your custom functions and aliases can be added to:
`~/.dotfiles/zsh/custom/functions.zsh`

### Adding OS-Specific Configurations

To add support for a new OS or modify an existing one, create or edit a file in:
`~/.dotfiles/zsh/os-specific/`

### Extending Neovim Configuration

Neovim plugins are managed in `~/.dotfiles/.config/nvim/init.lua`. You can easily add new plugins or modify existing configurations there.

---

## ❓ Troubleshooting

- **Zsh plugins not loading?** Make sure Oh My Zsh is installed correctly. You might need to re-source your `.zshrc` or restart your terminal.
- **Neovim plugins missing?** Run `:PackerSync` in Neovim to install/update plugins.
- **LSP servers not working?** Verify your setup with `:LspInfo` and run the LSP setup script if needed: `~/.dotfiles/scripts/setup_lsp.sh`.

---

## 📜 License

This project is licensed under the MIT License.

---

## 🙏 Acknowledgements

This setup wouldn't be possible without the amazing work of the open-source community. Special thanks to:
- Oh My Zsh
- Spaceship Prompt
- Neovim and its incredible plugin ecosystem

