local M = {}

function M.setup()
  -- Setup lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  -- Plugins configuration
  require("lazy").setup({
  -- Core plugins
  {
    "folke/lazy.nvim",
    version = "*",
    lazy = false,
  },

  -- AI Integration
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
          auto_trigger = false,
        },
        panel = {
          enabled = true,
          auto_refresh = false,
        },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = { "<leader>e" },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- Fuzzy Finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", ":Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", ":Telescope live_grep<CR>", desc = "Find text" },
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup({
            ui = {
              icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
              }
            }
          })
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        config = function()
          require("mason-lspconfig").setup({
            ensure_installed = {
              "lua_ls",       -- Lua
              "terraformls",  -- Terraform
              "ansiblels",    -- Ansible
              "dockerls",     -- Docker
              "docker_compose_language_service", -- Docker Compose
              "yamlls",       -- YAML
              "bashls",       -- Bash
              "jsonls",       -- JSON
              "pyright",      -- Python
              "gopls",        -- Go
            },
            automatic_installation = true,
          })
        end,
      },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- Configure individual LSP servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                ["https://json.schemastore.org/ansible-stable-2.9.json"] = "roles/tasks/*.{yml,yaml}",
              },
            },
          },
        },
        dockerls = {},
        docker_compose_language_service = {},
        pyright = {},
        gopls = {},
        terraformls = {},
        bashls = {},
        jsonls = {},
      }
      
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim",
      {
        "L3MON4D3/LuaSnip",
        build = (not jit.os:find("Windows")) and "make install_jsregexp" or nil,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "copilot", priority = 1000 },
          { name = "nvim_lsp", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500, keyword_length = 3 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            before = function(entry, vim_item)
              return vim_item
            end,
          }),
        },
        experimental = {
          ghost_text = true,
        },
      })
    end,
  },

  -- UI Components
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Color Scheme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require('configs.themes').setup()
    end,
  },
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim", as = "catppuccin" },
  { "rose-pine/neovim", as = "rose-pine" },
  { "EdenEast/nightfox.nvim" },
  { "navarasu/onedark.nvim" },
  { "marko-cerovac/material.nvim" },
  { "sainnhe/gruvbox-material" },
  { "sainnhe/sonokai" },
  { "sainnhe/edge" },
  { "dracula/vim" },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    config = function()
      require("toggleterm").setup({
        direction = "float",
      })
    end,
  },

  -- Git Integration
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  -- DevOps Tools
  { 'hashivim/vim-terraform', ft = 'terraform' },
  { 'pearofducks/ansible-vim', ft = 'ansible' },
  { 'ekalinin/Dockerfile.vim', ft = 'dockerfile' },
  { 'towolf/vim-helm', ft = 'helm' },
  { 'martinda/Jenkinsfile-vim-syntax', ft = 'jenkinsfile' },
  { 'chr4/nginx.vim', ft = 'nginx' },
  { 'fgsch/vim-varnish', ft = 'varnish' },
  { 'robbles/logstash.vim', ft = 'logstash' },
  { 'jvirtanen/vim-hcl', ft = 'hcl' },
  { 'tsandall/vim-rego', ft = 'rego' },
  { 'andrewstuart/vim-kubernetes', ft = 'kubernetes' },
  { 'vim-scripts/groovy.vim', ft = 'groovy' },

  -- Project Management
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" },
        patterns = {
          ".git", "_darcs", ".hg", ".bzr", ".svn",
          "Makefile", "package.json", "go.mod", "requirements.txt", "Cargo.toml"
        },
        show_hidden = false,
        silent_chdir = true,
      })
    end,
  },

  -- Code Formatting and Linting
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "jay-babu/mason-null-ls.nvim",
        config = function()
          require("mason-null-ls").setup({
            ensure_installed = {
              "stylua",       -- Lua formatter
              "terraform_fmt", -- Terraform formatter
              "yamlfmt",      -- YAML formatter
              "shellcheck",   -- Shell script linter
              "black",        -- Python formatter
              "isort",        -- Python import formatter
              "gofmt",        -- Go formatter
            },
            automatic_installation = true,
          })
        end,
      },
    },
  },

  -- Productivity plugins
  {
    'tpope/vim-surround',
    event = 'VeryLazy',
  },
  {
    'tpope/vim-commentary',
    event = 'VeryLazy',
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
  },
  {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = function()
      require('toggleterm').setup({
        direction = 'float',
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'bash', 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'javascript', 'typescript',
          'yaml', 'json', 'html', 'css', 'markdown', 'dockerfile', 'terraform', 'hcl',
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup({
        -- Your which-key configuration here
      })
    end,
  },
  {
    'folke/trouble.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup({
        -- Your trouble configuration here
      })
    end,
  },

  -- Clipboard Manager
  {
    "AckslD/nvim-neoclip.lua",
    event = 'VeryLazy',
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neoclip').setup()
    end,
  },
}, {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

end

return M
