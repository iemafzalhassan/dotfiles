local M = {}

-- Set leader key
vim.g.mapleader = " "

-- Initialize keymaps
function M.setup()
  -- Basic navigation
  M.setup_navigation()
  -- Window management
  M.setup_windows()
  -- Buffer management
  M.setup_buffers()
  -- Search and replace
  M.setup_search()
  -- File operations
  M.setup_files()
  -- Insert mode
  M.setup_insert_mode()
  M.setup_ai_tools()
end

-- Navigation keymaps
function M.setup_navigation()
  -- Window navigation
  vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
  vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to below window" })
  vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to above window" })
  vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

  -- Tab navigation
  vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
  vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
end

-- Window management keymaps
function M.setup_windows()
  -- Split navigation
  vim.keymap.set("n", "<leader>vs", ":vsplit<CR>", { desc = "Vertical split" })
  vim.keymap.set("n", "<leader>hs", ":split<CR>", { desc = "Horizontal split" })

  -- Resize splits
  vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease height" })
  vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase height" })
  vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease width" })
  vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

  -- Close window
  vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit current window" })
end

-- Buffer management keymaps
function M.setup_buffers()
  -- Buffer navigation
  vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
  vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })

  -- Buffer operations
  vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
  vim.keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
end

-- Search and replace keymaps
function M.setup_search()
  -- Search
  vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlights" })
  vim.keymap.set("n", "<leader>n", ":nohlsearch<CR>", { desc = "Clear search highlights" })
end

-- File operations keymaps
function M.setup_files()
  -- File operations
  vim.keymap.set("n", "<leader>e", ":e ", { desc = "Edit file" })
  vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
  vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
  vim.keymap.set("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
end

-- Insert mode keymaps
function M.setup_insert_mode()
  -- Exit insert mode
  vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
  vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

  -- Trigger Copilot
  vim.keymap.set("i", "<F2>", "<cmd>Copilot panel<CR>", { desc = "Trigger Copilot" })
end

-- AI Tools keymaps (Normal mode)
function M.setup_ai_tools()
  -- Copilot triggers
  vim.keymap.set("n", "<leader>cp", "<cmd>Copilot panel<CR>", { desc = "Open Copilot panel" })
  vim.keymap.set("n", "<F2>", "<cmd>Copilot panel<CR>", { desc = "Trigger Copilot" })
  vim.keymap.set("n", "<leader>cs", "<cmd>Copilot suggest<CR>", { desc = "Get Copilot suggestion" })
end

return M
