local dap = require('dap')
local dapui = require('dapui')
local dap_virtual_text = require('nvim-dap-virtual-text')

-- Configure DAP UI
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 10,
      position = "bottom",
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = "single",
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil,
    max_value_lines = 100,
  }
})

-- Configure DAP Virtual Text
dap_virtual_text.setup {
  enabled = true,                        -- enable this plugin
  enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle
  highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged
  highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables
  commented = false,                     -- prefix virtual text with comment string
  show_stop_reason = true,               -- show stop reason when stopped for exceptions
  virt_text_pos = 'eol',                 -- position the virtual text
  all_frames = false,                    -- show virtual text for all stack frames not only current
  virt_lines = false,                    -- show virtual lines instead of virtual text
  virt_text_win_col = nil                -- position the virtual text at a fixed window column
}

-- Initialize DAP Go
require('dap-go').setup {}

-- Initialize DAP Python
require('dap-python').setup('python')

-- Automatically open and close the DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Custom Signs for DAP
vim.fn.sign_define('DapBreakpoint', {text='🔴', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='▶️', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointRejected', {text='⭕', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='🟠', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='🔵', texthl='', linehl='', numhl=''})

-- Configure DAP for specific languages
-- JavaScript/TypeScript adapter
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {vim.fn.stdpath('data') .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js'},
}
dap.configurations.javascript = {
  {
    name = 'Launch',
    type = 'node2',
    request = 'launch',
    program = '${file}',
    cwd = vim.fn.getcwd(),
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require('dap.utils').pick_process,
  },
}
dap.configurations.typescript = dap.configurations.javascript

-- Return dap for module usage
return {
  dap = dap,
  dapui = dapui
}
