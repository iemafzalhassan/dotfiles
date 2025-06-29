-- macOS-specific Neovim configuration
local M = {}

function M.setup()
  -- Only run this setup on macOS
  if vim.fn.has('macunix') == 0 then
    return
  end

  -- =============================================================================
  -- Clipboard Integration
  -- =============================================================================
  -- Use macOS system clipboard as the default register
  vim.opt.clipboard = 'unnamedplus'

  -- =============================================================================
  -- Keybindings for macOS
  -- =============================================================================
  -- Use the Command key for common operations
  vim.keymap.set('n', '<D-s>', ':w<CR>', { silent = true, desc = 'Save file' })
  vim.keymap.set('v', '<D-c>', '"+y', { silent = true, desc = 'Copy to clipboard' })
  vim.keymap.set('n', '<D-v>', '"+P', { silent = true, desc = 'Paste from clipboard' })
  vim.keymap.set('i', '<D-v>', '<C-R>+', { silent = true, desc = 'Paste from clipboard' })
  vim.keymap.set('n', '<D-z>', 'u', { silent = true, desc = 'Undo' })
  vim.keymap.set('n', '<D-S-z>', '<C-r>', { silent = true, desc = 'Redo' })
  vim.keymap.set('n', '<D-f>', '/', { desc = 'Find' })
  vim.keymap.set('n', '<D-q>', ':qa!<CR>', { silent = true, desc = 'Quit Neovim' })

  -- =============================================================================
  -- Filesystem and Performance Optimizations
  -- =============================================================================
  -- More aggressive saving to prevent data loss on system sleep/crash
  vim.opt.updatetime = 300 -- Faster update time for CursorHold events

  -- Use macOS temporary directory for swap and backup files
  local tmp_dir = '/private/tmp/nvim'
  if vim.fn.isdirectory(tmp_dir) == 0 then
    vim.fn.mkdir(tmp_dir, 'p')
  end
  vim.opt.directory = tmp_dir
  vim.opt.backupdir = tmp_dir
  vim.opt.undodir = tmp_dir .. '/undodir'
  vim.opt.undofile = true

  -- =============================================================================
  -- Terminal Integration for iTerm2
  -- =============================================================================
  if vim.env.TERM_PROGRAM == 'iTerm.app' then
    -- Enable better cursor shapes and colors in iTerm2
    vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'
  end
end

return M 