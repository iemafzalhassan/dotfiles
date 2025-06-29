local M = {}

-- Create command group
local function create_command_group(name)
  vim.api.nvim_create_augroup("nvim_commands", { clear = true })
end

-- Initialize commands
function M.setup()
  -- Create command group
  create_command_group()

  -- Theme management
  vim.api.nvim_create_user_command("CycleTheme", function()
    local themes = {
      'tokyonight', 'tokyonight-night', 'tokyonight-storm', 'tokyonight-day', 'tokyonight-moon',
      'catppuccin', 'catppuccin-latte', 'catppuccin-frappe', 'catppuccin-macchiato', 'catppuccin-mocha',
      'rose-pine', 'rose-pine-moon', 'rose-pine-dawn',
      'nightfox', 'dayfox', 'dawnfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox',
      'onedark', 
      'material', 'material-darker', 'material-lighter', 'material-oceanic', 'material-palenight', 'material-deep-ocean',
      'gruvbox-material',
      'sonokai',
      'edge',
      'kanagawa', 'kanagawa-wave', 'kanagawa-dragon', 'kanagawa-lotus'
    }
    
    local current_theme = vim.g.colors_name or 'default'
    local theme_index = 1
    
    for i, theme in ipairs(themes) do
      if theme == current_theme then
        theme_index = i
        break
      end
    end
    
    theme_index = theme_index % #themes + 1
    local next_theme = themes[theme_index]
    
    local success, err = pcall(function()
      vim.cmd('colorscheme ' .. next_theme)
    end)
    
    if success then
      print('Theme: ' .. next_theme)
    else
      print('Failed to load theme: ' .. next_theme .. '. Error: ' .. err)
    end
  end, { desc = "Cycle through available themes" })

  -- Show available themes
  vim.api.nvim_create_user_command("ShowThemes", function()
    local themes = vim.fn.getcompletion('', 'color')
    local theme_list = table.concat(themes, '\n')
    vim.cmd('echo "' .. theme_list .. '"')
  end, { desc = "Show all available themes" })

  -- Buffer management
  vim.api.nvim_create_user_command("BufferDelete", function()
    vim.cmd('bd')
  end, { desc = "Delete current buffer" })

  -- Window management
  vim.api.nvim_create_user_command("SplitHorizontal", function()
    vim.cmd('split')
  end, { desc = "Split window horizontally" })

  vim.api.nvim_create_user_command("SplitVertical", function()
    vim.cmd('vsplit')
  end, { desc = "Split window vertically" })

  -- Git commands
  vim.api.nvim_create_user_command("GitStatus", function()
    vim.cmd('Git')
  end, { desc = "Show git status" })

  vim.api.nvim_create_user_command("GitCommit", function()
    vim.cmd('Git commit')
  end, { desc = "Create git commit" })

  vim.api.nvim_create_user_command("GitPush", function()
    vim.cmd('Git push')
  end, { desc = "Push git changes" })

  -- Terminal commands
  vim.api.nvim_create_user_command("ToggleTerminal", function()
    vim.cmd('ToggleTerm')
  end, { desc = "Toggle terminal" })

  vim.api.nvim_create_user_command("ToggleLazygit", function()
    vim.cmd('LazyGit')
  end, { desc = "Toggle lazygit" })
end

return M
