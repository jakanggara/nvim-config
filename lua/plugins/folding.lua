-- File: lua/plugins/folding.lua
return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    lazy = false,  -- Load immediately, not lazy
    priority = 1000,  -- Load early, before other plugins
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        -- IMPORTANT: treesitter as fallback can throw UfoFallbackException
        -- Always use 'indent' as the ultimate fallback - it never fails
        -- Use treesitter as MAIN provider for files without LSP support
        local ftMap = {
          vim = { "treesitter", "indent" },
          python = { "lsp", "indent" },
          rust = { "lsp", "indent" },
          lua = { "lsp", "indent" },
          javascript = { "lsp", "indent" },
          typescript = { "lsp", "indent" },
          go = { "lsp", "indent" },
        }
        return ftMap[filetype] or { "indent", "indent" }
      end,
      -- Show fold preview when hovering over closed fold
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      -- Fold column settings
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    },
    config = function(_, opts)
      -- Setup ufo
      print("[UFO] Loading nvim-ufo configuration...")
      require("ufo").setup(opts)
      print("[UFO] nvim-ufo setup complete")

      -- Disable folding for neo-tree and other special buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "neo-tree", "neo-tree-popup", "notify", "TelescopePrompt" },
        callback = function()
          vim.wo.foldenable = false
          vim.wo.foldcolumn = "0"
        end,
      })

      -- Set fold column to show fold indicators
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Prevent auto-closing folds when moving between windows/buffers
      vim.o.foldclose = ""  -- Don't auto-close folds (default: "")
      vim.o.foldopen = "block,hor,mark,percent,quickfix,search,tag,undo"  -- When to auto-open

      -- Disable automatic view saving/loading which can interfere with fold state
      vim.o.viewoptions = "cursor,curdir"  -- Don't save folds in views

      print("[UFO] Fold settings applied: foldlevel=99, foldclose='', viewoptions=" .. vim.o.viewoptions)

      -- Using ufo provider need remap `zR` and `zM`
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })

      -- Peek fold preview
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold or hover" })
    end,
  },
}
