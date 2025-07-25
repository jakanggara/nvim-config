-- In your plugins/which-key.lua or wherever you define plugins
return {
  "folke/which-key.nvim",
  event = "VimEnter", -- Changed from "VeryLazy" to ensure early loading
  init = function()
    vim.opt.timeout = true
    vim.opt.timeoutlen = 300
  end,
  opts = {
    -- Your WhichKey configuration here
    delay = 0,
    -- triggers_blacklist = {
    --   n = { "gR" }, -- Example: exclude specific keys if needed
    -- },
  }
}

-- return {
--   "folke/which-key.nvim",
--   event = "VeryLazy",
--   opts = {
--     -- your configuration comes here
--     -- or leave it empty to use the default settings
--     -- refer to the configuration section below
--   },
--   keys = {
--     {
--       "<leader>?",
--       function()
--         require("which-key").show({ global = true })
--       end,
--       desc = "Buffer Local Keymaps (which-key)",
--     },
--   },
-- }
