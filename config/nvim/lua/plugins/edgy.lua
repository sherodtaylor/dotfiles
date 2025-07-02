return {
  "folke/edgy.nvim",
  event = "VeryLazy",
  opts = {
    bottom = {
      {
        ft = "terminal",
        title = "Claude Code",
        filter = function(buf)
          return vim.b[buf].claude_code or string.match(vim.api.nvim_buf_get_name(buf), "claude%-code")
        end,
        size = { height = 0.4 },
      },
      {
        ft = "terminal",
        title = "Terminal",
        filter = function(buf)
          local name = vim.api.nvim_buf_get_name(buf)
          return vim.bo[buf].buftype == "terminal" and 
                 not vim.b[buf].claude_code and 
                 not string.match(name, "claude%-code")
        end,
        size = { height = 0.4 },
      },
    },
    left = {
      {
        title = "Neo-Tree",
        ft = "neo-tree",
        filter = function(buf)
          return vim.bo[buf].filetype == "neo-tree"
        end,
        pinned = true,
        open = function()
          require("neo-tree.command").execute({ action = "show", source = "filesystem" })
        end,
        size = { width = 0.25 },
      },
    },
    right = {
      -- Add other sidebar windows here if needed
    },
    options = {
      left = { size = 30 },
      bottom = { size = 10 },
      right = { size = 30 },
      top = { size = 10 },
    },
  },
}