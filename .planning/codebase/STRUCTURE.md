# STRUCTURE — Directory Layout & Key Locations

**Analysis Date:** 2026-08-14

## Repo layout (`/Users/iemafzal/dotfiles`)

| Path | What it is | Live status |
|---|---|---|
| `.zshrc` | Main zsh config (~400 lines) | ⚠️ Stale — live `~/.zshrc` (420 lines) differs substantially |
| `.vimrc` | Legacy Vim config (165 lines, vim-plug, coc, ale…) | ⚠️ Stale — live `~/.vimrc` is 1 line: `set rtp+=/opt/homebrew/opt/fzf` |
| `.vim/` | Vendored vim-plug install (64 MB: nerdtree, coc.nvim, ale, gruvbox…) | ❌ Dead — no `~/.vim` on live machine; vim not used |
| `.oh-my-zsh/` | Full Oh My Zsh framework vendored (20 MB) + custom plugins | ⚠️ Duplicate — OMZ is installed fresh via curl; vendoring is redundant |
| `spaceship/config.zsh` | Prompt override (`SPACESHIP_PYTHON_SHOW=false`) | ✅ Matches live `~/.config/spaceship/config.zsh` byte-for-byte |
| `nvim/` | LazyVim Neovim config | ⚠️ Drifted — 3 files differ from live `~/.config/nvim` |
| `setup_env.sh` | Bootstrap/install script | ⚠️ Buggy — mojibake emoji, invalid plugin clone URLs, macOS-only |

## Neovim config (`nvim/` ↔ live `~/.config/nvim`)

```
nvim/
├── init.lua              # entry → require("config.lazy")
├── lazyvim.json          # LazyVim extras/version metadata
├── lazy-lock.json        # pinned plugin commits (DIFFERS from live — live is newer)
├── stylua.toml           # 2-space, 120 col
├── .neoconf.json         # neodev/neoconf lua_ls settings
├── .gitignore            # lazy.nvim artifacts
├── README.md             # stock LazyVim template
├── LICENSE
└── lua/
    ├── config/
    │   ├── lazy.lua      # lazy.nvim bootstrap + LazyVim import
    │   ├── options.lua   # python3 host, winborder, diagnostics, treesitter folds, perf (DIFFERS from live)
    │   ├── keymaps.lua   # LSP/diagnostic keymaps, <leader>pp/ps/hh/hu/hc/po
    │   └── autocmds.lua  # empty placeholder
    └── plugins/
        ├── custom.lua    # dracula transparent theme, blink.cmp, mason, lspconfig, treesitter (DIFFERS from live)
        └── example.lua   # disabled example spec
```

**Files differing repo vs live:** `lua/config/options.lua` (repo has `lazyredraw = true`
active; live commented out), `lua/plugins/custom.lua` (repo has `blink.cmp` block +
`mason lazy=false`; live lacks both), `lazy-lock.json` (different pinned commits — live
was updated via `Lazy update`).

## Live-only configs NOT in repo (must be added for the public repo)

| Live path | Content |
|---|---|
| `~/.config/ghostty/config` | Transparent theme: Hack Nerd Font Mono 20pt, bg-opacity 0.65, blur 15, "Builtin Pastel Dark", bar cursor `f5c2e7`, no window decoration, padding 20 |
| `~/.zprofile` | Kiro CLI pre/post, `brew shellenv`, OrbStack (stale), Antigravity PATH |
| `~/.zshenv` | `. "$HOME/.cargo/env"` |
| `~/.gitconfig` | delta pager, SSH signing, user identity, `safe.directory=*` |

## Live `~/.config/` — unmanaged extras (not part of dotfiles scope)

`1mcp btop cagent coc configstore containers crush Dadroit fish flutter gcloud gh
github-copilot goose gtk-3.0 jgit kilo manicode mcp-servers neofetch nvim opencode
raycast spaceship thefuck uv` — user decides which belong in the public repo.

## Naming conventions

- Dot-prefixed files in repo root map to `$HOME` (`.zshrc`, `.vimrc`)
- `~/.config/<app>/` for XDG apps (nvim, ghostty, spaceship)
- `setup_env.sh` links `spaceship/ → ~/.config/spaceship`, `nvim/ → ~/.config/nvim`
- Sections in `.zshrc` use `# ===== SECTION NAME =====` banners; repo uses 4-space
  indent, live uses 2-space (cosmetic drift)
