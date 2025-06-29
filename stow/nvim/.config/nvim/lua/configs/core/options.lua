local M = {}

function M.setup()
  -- Basic Neovim Options
  vim.opt.number = true          -- Show line numbers
  vim.opt.relativenumber = true  -- Show relative line numbers
  vim.opt.tabstop = 2            -- Tab width
  vim.opt.shiftwidth = 2         -- Indentation width
  vim.opt.expandtab = true       -- Use spaces instead of tabs
  vim.opt.smartindent = true     -- Smart indentation
  vim.opt.wrap = false           -- Don't wrap lines
end

return M
