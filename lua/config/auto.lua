-- Store view state per buffer for restoration after save
local saved_views = {}

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    -- Save current view (including fold state) before formatting
    saved_views[args.buf] = vim.fn.winsaveview()

    vim.lsp.buf.format()
    vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
    vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
  end,
})

vim.api.nvim_set_option("clipboard", "unnamedplus")
