-- Theme configuration
local M = {}

function M.setup()
  -- Define the list of available themes
  local themes = {
    "kanagawa",
    "tokyonight",
    "catppuccin",
    "rose-pine",
    "nightfox",
    "onedark",
    "material",
    "gruvbox-material",
    "sonokai",
    "edge",
    "dracula",
  }

  -- Set the default theme
  vim.g.theme_idx = 1
  vim.cmd("colorscheme " .. themes[vim.g.theme_idx])

  -- Function to cycle to the next theme
  local function cycle_theme(direction)
    vim.g.theme_idx = vim.g.theme_idx + direction
    if vim.g.theme_idx > #themes then
      vim.g.theme_idx = 1
    elseif vim.g.theme_idx < 1 then
      vim.g.theme_idx = #themes
    end

    local theme_name = themes[vim.g.theme_idx]
    pcall(vim.cmd, "colorscheme " .. theme_name)
    vim.notify("Theme set to: " .. theme_name, vim.log.levels.INFO)
  end

  -- Keybindings for theme switching
  vim.keymap.set('n', '<leader>thn', function() cycle_theme(1) end, { desc = "Next theme" })
  vim.keymap.set('n', '<leader>thp', function() cycle_theme(-1) end, { desc = "Previous theme" })
end

return M 