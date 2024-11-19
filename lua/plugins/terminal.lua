return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float Terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal Terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical Terminal" },
      { "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>", desc = "Tab Terminal" },
    },
    opts = {
      -- Basic settings
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = false,
      insert_mappings = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,

      -- Float settings
      float_opts = {
        border = "curved",
        winblend = 3,
        width = function()
          return math.floor(vim.o.columns * 0.85)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },

      -- Custom terminals
      winbar = {
        enabled = true,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Custom terminals
      local Terminal = require("toggleterm.terminal").Terminal

      -- Lazygit terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "double",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
        end,
      })

      -- Node terminal
      local node = Terminal:new({
        cmd = "node",
        direction = "vertical",
        hidden = true,
      })

      -- Python terminal
      local python = Terminal:new({
        cmd = "python3",
        direction = "vertical",
        hidden = true,
      })

      -- Custom keymaps for specific terminals
      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, {desc = "Lazygit"})
      vim.keymap.set("n", "<leader>tn", function() node:toggle() end, {desc = "Node"})
      vim.keymap.set("n", "<leader>tp", function() python:toggle() end, {desc = "Python"})

      -- Terminal keybindings
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end

      -- Auto commands
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      
      -- Terminal highlights
      vim.api.nvim_set_hl(0, "ToggleTermBorder", {link = "FloatBorder"})
    end,
  }
}
