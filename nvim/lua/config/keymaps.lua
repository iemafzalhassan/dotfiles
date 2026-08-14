-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Neovim 0.11+ Enhanced Keymaps
-- Leverage native LSP and diagnostic features

-- Enhanced LSP keymaps with native features
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "<leader>lD", vim.diagnostic.setqflist, { desc = "Set diagnostic quickfix list" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Native LSP completion enhancements
vim.keymap.set("i", "<C-Space>", function()
  if vim.lsp.completion.enabled() then
    vim.lsp.completion.trigger()
  end
end, { desc = "Trigger LSP completion" })

-- Enhanced hover with native LSP
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show LSP hover documentation" })

-- Phase 3 Fine-tuning: Maintenance and monitoring keymaps
-- Performance monitoring
vim.keymap.set("n", "<leader>pp", function()
  vim.cmd("Lazy profile")
end, { desc = "Profile plugin startup time" })

vim.keymap.set("n", "<leader>ps", function()
  vim.cmd("Lazy stats")
end, { desc = "Show plugin usage statistics" })

-- Health and maintenance
vim.keymap.set("n", "<leader>hh", function()
  vim.cmd("checkhealth")
end, { desc = "Run health check" })

vim.keymap.set("n", "<leader>hu", function()
  vim.cmd("Lazy update")
end, { desc = "Update all plugins" })

vim.keymap.set("n", "<leader>hc", function()
  vim.cmd("Lazy clean")
end, { desc = "Clean unused plugins" })

-- Performance optimization
vim.keymap.set("n", "<leader>po", function()
  vim.cmd("Lazy reload")
end, { desc = "Reload LazyVim configuration" })
