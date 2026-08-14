# CONVENTIONS — Style, Patterns & Error Handling

**Analysis Date:** 2026-08-14

## Shell (`.zshrc`, `setup_env.sh`)

- **Section banners**: `# ===== NAME =====` used to organize `.zshrc`; each tool block
  self-contained (PATH, FZF, NVM, Spaceship, aliases, functions).
- **Guarded command use**: most tools are checked with `command -v <tool>` before use
  (e.g. `zoxide`, `rg`, `bat`, `eza`, `tldr`, `tmux`) with a fallback (e.g. `find`/`cat`/`ls`).
- **Indentation drift**: repo `.zshrc` uses 4-space indent; live `~/.zshrc` uses 2-space.
  Not enforced by any linter (no `shellcheck`/`shfmt` config in repo, though
  `setup_env.sh` is `bash` with `set -euo pipefail`).
- **Path style**: Homebrew Apple-Silicon prefix `/opt/homebrew` hardcoded everywhere;
  `typeset -U path` + array build for dedup/performance; `JAVA_HOME` conditional on
  SDKMAN dir existence.
- **Functions** are lowercase descriptive names: `extract()`, `port()`, `fcd()`,
  `fopen()`, `fenv()`, `ftmux()`, `sdk()` (lazy-load pattern: `unset -f sdk` then source
  and re-dispatch).
- **Aliases** group: `ls/l/la/ll/lt/ltg/tree/treeall` (eza), `ff/fe/ft` (fzf helpers),
  `lg/ld` (lazygit/lazydocker), `vi/vim→nvim`, `cat→bat`, `man→tldr`, `sysinfo→neofetch`,
  `rgf` (rg→fzf→bat pipeline).
- **setopts** for history/dirstack declared with inline comments explaining each flag.
- **Error handling**: `set -euo pipefail` in `setup_env.sh`; `|| true` used to swallow
  non-fatal steps; `2>/dev/null` liberal suppression.

## Neovim (Lua)

- LazyVim conventions: `lua/config/*.lua` for core, `lua/plugins/*.lua` for plugin
  specs; specs return tables; `opts` merged with LazyVim defaults.
- **stylua** enforced style: `stylua.toml` — 2-space indent, 120 column width.
- Keymaps use `vim.keymap.set` with `desc = "..."` for which-key integration.
- Theme overrides centralized in `custom.lua` `opts.overrides` (Dracula palette:
  bg `#282A36`, pink `#FF79C6`, cyan `#8BE9FD`, green `#50FA7B`, etc.) with
  `transparent_bg = true`; `Normal = { bg = "none" }` etc.
- Disabled plugins declared explicitly: `{ "catppuccin/nvim", enabled = false }`.
- `lua/plugins/example.lua` intentionally no-ops (`if true then return {} end`).

## Ghostty (live only)

- Key = value, lowercase keys, hex colors without `#`, comments with `#`.
- `font-family = "Hack Nerd Font Mono"`, `font-size = 20`, transparency via
  `background-opacity` + `background-blur`.

## Git

- Global config in `~/.gitconfig` (delta pager, SSH commit signing). Repo has **no**
  `.gitignore` and **no** `.gitattributes`.

## What is NOT conventional (to fix)

1. **Secrets in live `.zshrc`** — API keys inline; must move to `~/.zshrc.local` /
   env files / keychain before any public publish.
2. **No `.gitignore`** — `.DS_Store`, `node_modules`, backups, 84 MB vendored dirs
   would be committed.
3. **Machine-specific config in shared files** — k3s, multipass, Antigravity/Windsurf
   paths, OrbStack reference, iTerm2 — should be OS/`hostname`-gated or moved to a
   local-only file.
4. **Split-brain prompt config** — spaceship settings duplicated in three places.
5. **Stale vendored frameworks** — committing `.oh-my-zsh/` and `.vim/` wholesale
   contradicts the "install via script" convention the rest of the repo follows.
