-- File: lua/plugins/lsp.lua

local servers = {
  "jsonls",
  "yamlls",
  "sqls",
  "gopls",
  "lua_ls",
  "ts_ls",
  "dockerls",
  "biome",
  "jdtls",
  "cssls",
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local masonlsp = require("mason-lspconfig")

      -- Keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = ev.buf, desc = desc })
          end

          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "K", vim.lsp.buf.hover, "Hover Information")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
          map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
          map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, "List Workspace Folders")
          map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "gr", vim.lsp.buf.references, "Go to References")

          -- Diagnostic key mappings
          map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "<leader>q", vim.diagnostic.setloclist, "Open Diagnostics List")
        end,
      })

      masonlsp.setup({
        ensure_installed = servers,
        automatic_instalation = true
      })

      -- Server configurations
      masonlsp.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    config = true,
    ens
  },
}
