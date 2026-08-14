-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Configure Python provider to use virtual environment
vim.g.python3_host_prog = vim.fn.expand("~/.neovim-python/bin/python")

-- Neovim 0.11+ Optimizations
-- Enable native LSP features
vim.opt.winborder = "rounded" -- Rounded borders for floating windows (Neovim 0.11+)

-- Enhanced diagnostics with virtual text
vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
    source = "always",
  },
  float = {
    border = "rounded",
    source = "always",
  },
})

-- Optimize treesitter performance (Neovim 0.11+ improvements)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false -- Start with folds open for better performance

-- Phase 3 Fine-tuning: Performance optimizations
-- Optimize redraw performance
-- vim.opt.lazyredraw = true -- Don't redraw during macro execution
vim.opt.updatetime = 250 -- Faster completion and diagnostics

-- Memory and performance optimizations
vim.opt.history = 1000 -- Increase command history
vim.opt.undolevels = 1000 -- Increase undo levels
vim.opt.swapfile = false -- Disable swap files for better performance
vim.opt.backup = false -- Disable backup files
vim.opt.writebackup = false -- Disable write backup

-- Optimize search performance
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
