return {
  -- Your existing nvim-cmp config with Codeium added
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "brenoprata10/nvim-highlight-colors",
      "Exafunction/codeium.nvim", -- Add Codeium as dependency
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local highlight = require("nvim-highlight-colors")

      require("luasnip.loaders.from_vscode").lazy_load()

      -- Custom highlight groups for better styling
      vim.api.nvim_set_hl(0, "CmpPmenu", { bg = "#1e1e2e", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#181825", fg = "#cdd6f4" })
      vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#585b70", italic = true })

      -- Highlight groups for different completion sources
      vim.api.nvim_set_hl(0, "CmpItemKindCodeium", { fg = "#09B6A2", bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "CmpItemKindLsp", { fg = "#E06C75", bg = "#1e1e2e" })
      vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#98C379", bg = "#1e1e2e" })

      highlight.setup({
        render = 'virtual',
        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = true,
        enable_hsl = true,
        enable_var_usage = true,
        enable_named_colors = true,
        virtual_symbol = '■',
        virtual_symbol_prefix = '',
        virtual_symbol_suffix = ' ',
        virtual_symbol_position = 'inline',
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            scrollbar = "║",
            winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            winhighlight = "Normal:CmpDoc",
          },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "codeium",  priority = 1000 }, -- Highest priority for Codeium
          { name = "nvim_lsp", priority = 900 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500, keyword_length = 3 },
          { name = "path",     priority = 250 },
          { name = "dadbod",   priority = 100 },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Apply color highlighting first
            vim_item = highlight.format(entry, vim_item)

            -- Kind icons
            local kind_icons = {
              Text = "󰉿",
              Method = "󰆧",
              Function = "󰊕",
              Constructor = "",
              Field = "󰜢",
              Variable = "󰀫",
              Class = "󰠱",
              Interface = "",
              Module = "",
              Property = "󰜢",
              Unit = "󰑭",
              Value = "󰎠",
              Enum = "",
              Keyword = "󰌋",
              Snippet = "",
              Color = "󰏘",
              File = "󰈙",
              Reference = "󰈇",
              Folder = "󰉋",
              EnumMember = "",
              Constant = "󰏿",
              Struct = "󰙅",
              Event = "",
              Operator = "󰆕",
              TypeParameter = "",
            }

            -- Source menu with colors and icons
            local source_mapping = {
              codeium = { icon = "󰚩", name = "AI", color = "#09B6A2" },
              nvim_lsp = { icon = "", name = "LSP", color = "#E06C75" },
              luasnip = { icon = "", name = "Snip", color = "#98C379" },
              buffer = { icon = "󰓩", name = "Buf", color = "#61AFEF" },
              path = { icon = "", name = "Path", color = "#D19A66" },
              dadbod = { icon = "", name = "DB", color = "#C678DD" },
            }

            -- Set kind icon
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

            -- Set source info
            local source_info = source_mapping[entry.source.name]
            if source_info then
              vim_item.menu = string.format("[%s %s]", source_info.icon, source_info.name)
            else
              vim_item.menu = string.format("[%s]", entry.source.name)
            end

            -- Truncate long completions
            if string.len(vim_item.abbr) > 50 then
              vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. "..."
            end

            return vim_item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        performance = {
          debounce = 60,
          throttle = 30,
          fetching_timeout = 500,
          confirm_resolve_timeout = 80,
          async_budget = 1,
          max_view_entries = 200,
        },
      })
    end,
  },
}
