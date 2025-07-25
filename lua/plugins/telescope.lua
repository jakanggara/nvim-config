-- Telescope Configuration for Neovim using lazy.nvim
-- Place this in your lua/plugins/telescope.lua file

return {
  -- Telescope core plugin
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      -- FZF sorter for better performance
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- File browser extension
      'nvim-telescope/telescope-file-browser.nvim',
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          -- Default configuration for telescope
          prompt_prefix = "❯ ",
          selection_caret = "❯ ",
          path_display = { "truncate" },
          file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },

          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-h>"] = actions.which_key,
              ["<esc>"] = actions.close,
            },
          },
          layout_config = {
            horizontal = {
              width = 0.9,
              height = 0.85,
              preview_width = 0.55,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            theme = "dropdown",
            hijack_netrw = true,
          },
        },
      })

      -- Load extensions
      telescope.load_extension('fzf')
      telescope.load_extension('file_browser')

      -- Keymaps
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Find files
      keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', opts)
      -- Find in files (grep)
      keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', opts)
      -- Browse files
      keymap('n', '<leader>fb', '<cmd>Telescope file_browser<CR>', opts)
      -- Buffers
      keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', opts)
      -- Help tags
      keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', opts)
      -- Git status
      keymap('n', '<leader>gs', '<cmd>Telescope git_status<CR>', opts)
      -- Git commits
      keymap('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', opts)
    end,
  }
}
