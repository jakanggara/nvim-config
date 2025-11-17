vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    vim.lsp.buf.format()
    vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
    vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nvcheatsheet", "neo-tree" },
  callback = function()
    require("ufo").detach()
    vim.opt_local.foldenable = false
    vim.opt_local.foldcolumn = '0'
  end
})

vim.api.nvim_set_option("clipboard", "unnamedplus")
