local M = {}

-- Initialize core configurations
function M.setup()
  -- Load basic core configurations
  require('configs.core.options').setup()
  require('configs.core.keymaps').setup()
  -- require('configs.themes').setup() -- This is loaded from the plugin config
  require('configs.macos').setup()

  -- Load autocmds and commands if they exist
  pcall(require, 'configs.core.autocmds')
  pcall(require, 'configs.core.commands')
end

return M
