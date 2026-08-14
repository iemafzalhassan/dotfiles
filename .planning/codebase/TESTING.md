# TESTING — Verification & Validation

**Analysis Date:** 2026-08-14

## Current state

**No automated tests exist.** This is a config repo; verification is manual and ad hoc.
The only "test" artifacts are shell/plugin state on the live machine.

## Manual verification steps (what the user actually does)

| Check | Command | Purpose |
|---|---|---|
| zsh syntax | `zsh -n ~/.zshrc` | Catch parse errors |
| bash syntax | `bash -n setup_env.sh` | Validate bootstrap script |
| Lua syntax | `nvim --headless -c 'luafile %'` / `:checkhealth` | Validate nvim config |
| LazyVim | `:Lazy health`, `:Lazy profile`, `:Lazy stats` | Plugin/startup health |
| Plugin update | `:Lazy update` | Refresh `lazy-lock.json` |
| Ghostty | `ghostty +list-themes`, `cmd+,` reload | Validate terminal config |
| Prompt | spawn new zsh | Verify spaceship renders |
| fzf | `Ctrl-T`, `Alt-C`, `ff/fe/ft` | Verify bindings/previews |

## What SHOULD be added (for a public repo)

- **CI lint job** (GitHub Actions): `zsh -n`, `bash -n`, `stylua --check` (nvim),
  `shellcheck setup_env.sh`, `yamllint` if YAML added.
- **Idempotency test** for `setup_env.sh`: run twice on a throwaway VM/container
  (macOS + Linux), assert no duplication of symlinks/install entries.
- **Dry-run mode**: `setup_env.sh --dry-run` printing planned actions without executing.
- **Structure test**: assert repo files match a manifest (e.g. every managed path exists
  after linking) — guards against the drift seen today.
- **Secret scan in CI**: `gitleaks`/`trufflehog` to block API keys from ever landing
  in the public repo (live `.zshrc` currently contains keys — a real risk).

## Testing constraints

- `setup_env.sh` is macOS/brew-specific today; any CI that exercises it must run on
  macOS runners (or be refactored to detect OS first).
- nvim plugin install requires network + `git`; keep CI checks to static analysis
  unless a dedicated container image with Neovim is built.
