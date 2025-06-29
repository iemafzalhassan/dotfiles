-- Neotest setup
local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-go")({
      args = { "-v", "-count=1", "-timeout=60s" }
    }),
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
    }),
    require("neotest-rust"),
  },
  icons = {
    running = "⟳",
    passed = "✓",
    failed = "✗",
    skipped = "↓",
    unknown = "?"
  },
  floating = {
    border = "rounded",
    max_height = 0.8,
    max_width = 0.8,
  },
  summary = {
    open = "botright vsplit | vertical resize 50"
  },
  output = {
    open_on_run = true,
  },
  quickfix = {
    open = function()
      vim.cmd("copen")
    end,
  },
})

return neotest
