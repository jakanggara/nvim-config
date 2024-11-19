-- File: lua/plugins/coding.lua
return {
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  -- Surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },
  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },
  -- Language: GO
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end
  }
}
