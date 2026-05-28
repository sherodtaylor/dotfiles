return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {},
    delay = 300, -- Reduce delay to show which-key faster
    spec = {
      {
        mode = { "n", "v" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui" },
        { "<leader>w", group = "windows" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>t", group = "terminal" },
        { "<leader>d", group = "debug/diagnostics" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "z", group = "fold" },
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
  end,
}