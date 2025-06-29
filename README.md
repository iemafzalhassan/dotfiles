# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A meticulously crafted, cross-platform configuration for a powerful and beautiful development environment. This setup focuses on elegance, speed, and a seamless DevOps workflow, leveraging Zsh, Neovim, and a suite of modern command-line tools. It is designed to be fully reproducible and works flawlessly across macOS, Debian, Arch, and RHEL-based systems.

---

## ✨ Features

This configuration is built on a foundation of modern, fast, and powerful tools, ensuring a consistent and efficient workflow everywhere.

-   **Cross-Platform by Design**: A single, unified experience on macOS and major Linux distributions.
-   **Automated & Idempotent Installation**: The `install.sh` script handles OS detection, dependency installation, and symlinking via `stow`, making setup a breeze.
-   **The Ultimate Shell Experience**: Zsh powered by the sleek and powerful **Spaceship Prompt**.
-   **Next-Generation Neovim IDE**: A lightning-fast, fully-featured Neovim setup managed by **Lazy.nvim**. It includes LSP, autocompletion, fuzzy finding, and AI-powered assistance with GitHub Copilot.
-   **Modular Alias System**: A clean, organized approach to shell aliases, with dedicated files for `git`, `docker`, `kubernetes`, and more.
-   **Git Enhancement**: A superior Git experience with **Delta** for beautiful diffs and `lazygit` for an intuitive terminal UI.

---

## 🛠️ What's Included

### 🐚 Shell Environment (Zsh)

-   **Prompt**: **[Spaceship Prompt](https://spaceship-prompt.sh/)** for a minimal, powerful, and customizable Zsh prompt.
-   **Syntax Highlighting**: **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** for real-time command highlighting.
-   **Autosuggestions**: **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** for fish-like autosuggestions based on command history.
-   **Fuzzy Finding**: Integrated **[fzf](https://github.com/junegunn/fzf)** for blazing-fast history search (`Ctrl+R`) and directory jumping.
-   **Modular Aliases**: A clean `~/.zshrc` that sources aliases from `~/.config/zsh/aliases/`, keeping your shell configuration organized and easy to extend.

### 💻 Editor Setup (Neovim with Lazy.nvim)

A complete IDE experience centered around performance and modern tooling.

-   **Plugin Manager**: **[Lazy.nvim](https://github.com/folke/lazy.nvim)** for declarative, fast, and robust plugin management.
-   **AI-Assisted Coding**: **[GitHub Copilot](https://github.com/github/copilot.vim)** integrated with a manual trigger (`<leader>cp` or `<F2>`) to provide suggestions on demand without being intrusive.
-   **LSP & Autocompletion**: **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** and **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** for intelligent, language-aware completion and diagnostics.
-   **Modern UI**: A beautiful and functional UI powered by **[Catppuccin Theme](https://github.com/catppuccin/nvim)**, **[lualine](https://github.com/nvim-lualine/lualine.nvim)**, and **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)**.
-   **File Navigation**: **[Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)** for finding files, text, and more, complemented by **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)** for a file explorer sidebar.
-   **Git Integration**: **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** for Git decorations and **[lazygit](https://github.com/jesseduffield/lazygit)** for a full-featured Git TUI.
-   **Enhanced Diffs**: **[Delta](https://github.com/dandavison/delta)** configured for beautiful and readable `git diff` output.

---

## 🚀 Installation

The installation process is designed to be simple and robust.

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/iemafzal/dotfiles.git ~/.dotfiles
    ```

2.  **Run the Installer**:
    The main installation script will detect your OS, install all necessary dependencies using the appropriate package manager, and symlink the configuration files into place with `stow`.
    ```bash
    cd ~/.dotfiles
    ./install.sh
    ```

3.  **Restart Your Shell**:
    Once the installation is complete, restart your shell or source your `.zshrc` to apply the changes.

    Open Neovim (`nvim`) for the first time. Lazy.nvim will automatically install all the plugins.

---

## 🙏 Acknowledgements & Credits

This setup stands on the shoulders of giants. A huge thank you to the creators and maintainers of these incredible open-source projects:

-   **[Neovim](https://neovim.io/)**: For being the best editor on the planet.
-   **[Lazy.nvim](https://github.com/folke/lazy.nvim)**: For revolutionizing Neovim plugin management.
-   **[Spaceship Prompt](https://spaceship-prompt.sh/)**: For a beautiful and functional Zsh prompt.
-   **[Stow](https://www.gnu.org/software/stow/)**: For elegant symlink management.
-   **[Delta](https://github.com/dandavison/delta)**: For making code reviews a pleasure.
-   **[lazygit](https://github.com/jesseduffield/lazygit)**: For simplifying complex Git operations.
-   **The entire Neovim plugin community**: Especially the authors of Telescope, Lualine, nvim-tree, and Catppuccin.

---

## 📜 License

This project is licensed under the MIT License.

