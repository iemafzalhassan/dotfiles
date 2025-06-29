local M = {}

-- Create augroup for Neovim configuration
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Initialize autocmds
function M.setup()
  -- Filetype detection
  autocmd("FileType", {
    group = augroup("filetype_detection", { clear = true }),
    pattern = "*",
    callback = function()
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  })

  -- Highlight on yank
  autocmd("TextYankPost", {
    group = augroup("highlight_yank", { clear = true }),
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 400 })
    end,
  })

  -- Auto read when file changes
  autocmd("FocusGained", {
    group = augroup("auto_read", { clear = true }),
    callback = function()
      vim.cmd("checktime")
    end,
  })

  -- Auto format on save
  autocmd("BufWritePre", {
    group = augroup("auto_format", { clear = true }),
    pattern = "*.lua,*.go,*.py,*.js,*.ts,*.tsx,*.jsx,*.html,*.css,*.json,*.yaml,*.yml",
    callback = function()
      vim.lsp.buf.format({ async = true })
    end,
  })

  -- Auto resize splits
  autocmd("VimResized", {
    group = augroup("auto_resize", { clear = true }),
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
  })

  -- Cursor hold events
  autocmd("CursorHold", {
    group = augroup("cursor_hold", { clear = true }),
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })

  -- Terminal settings
  autocmd("TermOpen", {
    group = augroup("terminal_settings", { clear = true }),
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], { buffer = true })
      vim.keymap.set("t", "kj", [[<C-\><C-n>]], { buffer = true })
    end,
  })

  -- Git commit message
  autocmd("FileType", {
    group = augroup("git_commit", { clear = true }),
    pattern = "gitcommit",
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  })

  -- Markdown preview
  autocmd("FileType", {
    group = augroup("markdown_preview", { clear = true }),
    pattern = "*.md",
    callback = function()
      vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "Markdown preview", buffer = true })
      vim.keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", { desc = "Stop markdown preview", buffer = true })
    end,
  })
end

return M
