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

      -- Claude Code positioning presets
      local claude_positions = {
        center = {
          width = function() return math.floor(vim.o.columns * 0.85) end,
          height = function() return math.floor(vim.o.lines * 0.8) end,
          row = function() return math.floor(vim.o.lines * 0.1) end,
          col = function() return math.floor(vim.o.columns * 0.075) end,
        },
        top_left = {
          width = function() return math.floor(vim.o.columns * 0.48) end,
          height = function() return math.floor(vim.o.lines * 0.48) end,
          row = 1,
          col = 0,
        },
        top_right = {
          width = function() return math.floor(vim.o.columns * 0.48) end,
          height = function() return math.floor(vim.o.lines * 0.48) end,
          row = 1,
          col = function() return math.floor(vim.o.columns * 0.52) end,
        },
        bottom_left = {
          width = function() return math.floor(vim.o.columns * 0.48) end,
          height = function() return math.floor(vim.o.lines * 0.48) end,
          row = function() return math.floor(vim.o.lines * 0.52) end,
          col = 0,
        },
        bottom_right = {
          width = function() return math.floor(vim.o.columns * 0.48) end,
          height = function() return math.floor(vim.o.lines * 0.48) end,
          row = function() return math.floor(vim.o.lines * 0.52) end,
          col = function() return math.floor(vim.o.columns * 0.52) end,
        },
        top = {
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.45) end,
          row = 1,
          col = function() return math.floor(vim.o.columns * 0.05) end,
        },
        bottom = {
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.45) end,
          row = function() return math.floor(vim.o.lines * 0.55) end,
          col = function() return math.floor(vim.o.columns * 0.05) end,
        },
        left = {
          width = function() return math.floor(vim.o.columns * 0.45) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
          row = function() return math.floor(vim.o.lines * 0.05) end,
          col = 0,
        },
        right = {
          width = function() return math.floor(vim.o.columns * 0.45) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
          row = function() return math.floor(vim.o.lines * 0.05) end,
          col = function() return math.floor(vim.o.columns * 0.55) end,
        },
      }

      -- Current position state
      local current_position = "center"

      -- Helper function to get position values
      local function get_position_opts(position_name)
        local pos = claude_positions[position_name]
        return {
          width = type(pos.width) == "function" and pos.width() or pos.width,
          height = type(pos.height) == "function" and pos.height() or pos.height,
          row = type(pos.row) == "function" and pos.row() or pos.row,
          col = type(pos.col) == "function" and pos.col() or pos.col,
        }
      end

      -- Claude Code terminal
      local claude = Terminal:new({
        cmd = "claude-code",
        direction = "float",
        float_opts = vim.tbl_extend("force", {
          border = "rounded",
          winblend = 0,
        }, get_position_opts("center")),
        on_open = function(term)
          vim.cmd("startinsert!")
          -- Add keymaps for repositioning while terminal is open
          local buf_opts = { buffer = term.bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "<leader>tc", function() _G.reposition_claude("center") end, vim.tbl_extend("force", buf_opts, {desc = "Center"}))
          vim.keymap.set("n", "<leader>t1", function() _G.reposition_claude("top_left") end, vim.tbl_extend("force", buf_opts, {desc = "Top Left"}))
          vim.keymap.set("n", "<leader>t2", function() _G.reposition_claude("top") end, vim.tbl_extend("force", buf_opts, {desc = "Top"}))
          vim.keymap.set("n", "<leader>t3", function() _G.reposition_claude("top_right") end, vim.tbl_extend("force", buf_opts, {desc = "Top Right"}))
          vim.keymap.set("n", "<leader>t4", function() _G.reposition_claude("left") end, vim.tbl_extend("force", buf_opts, {desc = "Left"}))
          vim.keymap.set("n", "<leader>t6", function() _G.reposition_claude("right") end, vim.tbl_extend("force", buf_opts, {desc = "Right"}))
          vim.keymap.set("n", "<leader>t7", function() _G.reposition_claude("bottom_left") end, vim.tbl_extend("force", buf_opts, {desc = "Bottom Left"}))
          vim.keymap.set("n", "<leader>t8", function() _G.reposition_claude("bottom") end, vim.tbl_extend("force", buf_opts, {desc = "Bottom"}))
          vim.keymap.set("n", "<leader>t9", function() _G.reposition_claude("bottom_right") end, vim.tbl_extend("force", buf_opts, {desc = "Bottom Right"}))
          vim.keymap.set("n", "q", "<cmd>close<CR>", buf_opts)
        end,
      })

      -- Function to reposition claude terminal
      function _G.reposition_claude(position_name)
        if not claude_positions[position_name] then
          vim.notify("Invalid position: " .. position_name, vim.log.levels.ERROR)
          return
        end

        current_position = position_name
        local new_opts = get_position_opts(position_name)

        -- Update float_opts
        claude.float_opts = vim.tbl_extend("force", claude.float_opts or {}, new_opts)

        -- If terminal is open, close and reopen with new position
        if claude:is_open() then
          claude:close()
          vim.defer_fn(function()
            claude:open()
          end, 50)
        end
      end

      -- Custom keymaps for specific terminals
      vim.keymap.set("n", "<leader>tg", function() lazygit:toggle() end, {desc = "Lazygit"})
      vim.keymap.set("n", "<leader>tn", function() node:toggle() end, {desc = "Node"})
      vim.keymap.set("n", "<leader>tp", function() python:toggle() end, {desc = "Python"})

      -- Claude Code terminal keymaps
      vim.keymap.set("n", "<leader>cc", function() claude:toggle() end, {desc = "Claude Code Terminal"})
      vim.keymap.set("n", "<leader>c1", function() _G.reposition_claude("top_left"); claude:open() end, {desc = "Claude Top-Left"})
      vim.keymap.set("n", "<leader>c2", function() _G.reposition_claude("top"); claude:open() end, {desc = "Claude Top"})
      vim.keymap.set("n", "<leader>c3", function() _G.reposition_claude("top_right"); claude:open() end, {desc = "Claude Top-Right"})
      vim.keymap.set("n", "<leader>c4", function() _G.reposition_claude("left"); claude:open() end, {desc = "Claude Left"})
      vim.keymap.set("n", "<leader>c5", function() _G.reposition_claude("center"); claude:open() end, {desc = "Claude Center"})
      vim.keymap.set("n", "<leader>c6", function() _G.reposition_claude("right"); claude:open() end, {desc = "Claude Right"})
      vim.keymap.set("n", "<leader>c7", function() _G.reposition_claude("bottom_left"); claude:open() end, {desc = "Claude Bottom-Left"})
      vim.keymap.set("n", "<leader>c8", function() _G.reposition_claude("bottom"); claude:open() end, {desc = "Claude Bottom"})
      vim.keymap.set("n", "<leader>c9", function() _G.reposition_claude("bottom_right"); claude:open() end, {desc = "Claude Bottom-Right"})

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
