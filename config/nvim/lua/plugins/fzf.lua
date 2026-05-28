return {
  { "junegunn/fzf",
    lazy = false,
    build = "./install --bin"
  },
  {
    "ibhagwan/fzf-lua",
    lazy = false,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({
         defaults = {
          git_icons = false
        }
      })
    end
  }
}
