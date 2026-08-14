-- Minimal LazyVim Configuration
-- This avoids conflicts with LazyVim's built-in configurations

return {
  -- Configure LazyVim to use Dracula theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },

  -- Enhanced Dracula theme with transparency ONLY
  {
    "Mofiqul/dracula.nvim",
    priority = 1000, -- Load early
    opts = {
      colorscheme = "dracula",
      transparent_bg = true,  -- Enable transparency
      italic_comment = true,
      overrides = {
        -- CRITICAL: Make background transparent
        Normal = { bg = "none" },
        NormalNC = { bg = "none" },
        SignColumn = { bg = "none" },
        LineNr = { bg = "none" },
        CursorLine = { bg = "#44475A" },
        CursorLineNr = { fg = "#FF79C6", bg = "#44475A" },
        
        -- Status line with transparency
        StatusLine = { fg = "#F8F8F2", bg = "#282A36" },
        StatusLineNC = { fg = "#6272A4", bg = "#282A36" },
        
        -- Enhanced colors for better visibility with transparency
        Comment = { fg = "#6272A4", italic = true },
        String = { fg = "#F1FA8C" },
        Number = { fg = "#BD93F9" },
        Boolean = { fg = "#BD93F9" },
        Function = { fg = "#50FA7B" },
        Identifier = { fg = "#8BE9FD" },
        Statement = { fg = "#FF79C6" },
        Type = { fg = "#8BE9FD" },
        Special = { fg = "#FFB86C" },
        PreProc = { fg = "#FF79C6" },
        Constant = { fg = "#BD93F9" },
        
        -- Enhanced search highlighting
        Search = { fg = "#282A36", bg = "#FFB86C" },
        IncSearch = { fg = "#282A36", bg = "#50FA7B" },
        
        -- Enhanced git signs
        GitSignsAdd = { fg = "#50FA7B" },
        GitSignsChange = { fg = "#FFB86C" },
        GitSignsDelete = { fg = "#FF5555" },
        
        -- Additional transparency for UI elements
        Pmenu = { bg = "none" },
        PmenuSel = { bg = "#44475A" },
        PmenuSbar = { bg = "none" },
        PmenuThumb = { bg = "#6272A4" },
        
        -- Tab line transparency
        TabLine = { bg = "none" },
        TabLineFill = { bg = "none" },
        TabLineSel = { bg = "#44475A" },
        
        -- Float windows transparency
        FloatBorder = { bg = "none" },
        NormalFloat = { bg = "none" },
        
        -- Diagnostic transparency
        DiagnosticError = { fg = "#FF5555" },
        DiagnosticWarn = { fg = "#FFB86C" },
        DiagnosticInfo = { fg = "#8BE9FD" },
        DiagnosticHint = { fg = "#50FA7B" },
      },
    },
    config = function(_, opts)
      -- Apply theme with transparency
      vim.opt.background = "dark"
      vim.opt.termguicolors = true
      
      require("dracula").setup(opts)
      vim.cmd.colorscheme("dracula")
    end,
  },

  -- Let LazyVim handle plugin loading automatically for optimal performance
  -- Only force-load plugins that are absolutely necessary for startup
  { "mason-org/mason.nvim" },

  -- Neovim 0.11+ Native LSP Optimizations
  -- Leverage built-in LSP features for better performance
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Use native LSP features where possible
      servers = {
        -- Example: Configure servers with native LSP features
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { library = vim.api.nvim_get_runtime_file("", true) },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },

  

  -- Phase 3 Fine-tuning Optimizations
  -- Remove unused theme plugins to reduce resource usage
  { "catppuccin/nvim", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },

  -- Optimize plugin loading for better performance
  {
    "nvim-treesitter",
    opts = {
      -- Optimize treesitter performance
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    },
  },

  -- Optimize Mason for faster LSP installation
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- Let LazyVim handle the rest of plugins with its defaults
}
