-- Load core configurations
require('configs.core').setup()

-- Load plugin configuration
require('plugins').setup()

-- Basic Neovim settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Set leader key
vim.g.mapleader = " "

-- Basic keymaps
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- LSP keybindings
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })

-- Telescope keybindings
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').live_grep() end, { desc = 'Find text' })
vim.keymap.set('n', '<leader>fb', function() require('telescope.builtin').buffers() end, { desc = 'Find buffers' })

-- File explorer
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- Buffer navigation
vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })

-- Terminal
vim.keymap.set('n', '<leader>tf', function() require('toggleterm.terminal').Terminal:new({ direction = "float" }):toggle() end, { desc = 'Float terminal' })

-- Set colorscheme with fallback
pcall(function()
  vim.cmd([[colorscheme kanagawa]])
end)

-- If kanagawa fails, try a default
if vim.fn.exists('g:colors_name') == 0 then
  vim.cmd([[colorscheme default]])
end

-- Configure diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- Diagnostic signs
local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " "
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end
