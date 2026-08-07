require("nvchad.configs.lspconfig").defaults()

-- clangd. dreamsofcode used `lspconfig.clangd.setup{}`, the pre-0.11 API;
-- vim.lsp.config + vim.lsp.enable is the equivalent NvChad v2.5 ships with.
vim.lsp.config("clangd", {
  -- Without a compile_commands.json clangd assumes an older standard and
  -- flags valid C++23 as errors. fallbackFlags applies only when the project
  -- has no compile database -- a real one always wins.
  init_options = {
    fallbackFlags = { "-std=c++23" },
  },

  on_attach = function(client, _)
    -- Same as dreamsofcode's: the signature popup fights the completion menu.
    client.server_capabilities.signatureHelpProvider = false
  end,
})

vim.lsp.enable "clangd"

-- read :h vim.lsp.config for changing options of lsp servers
