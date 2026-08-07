-- Language servers. Spec: plugins/cpp.lua.
-- Servers are installed by mason-tool-installer, not from here.

require("nvchad.configs.lspconfig").defaults()

-- clangd ---------------------------------------------------------------------
-- vim.lsp.config + vim.lsp.enable is the Neovim 0.11 API NvChad v2.5 uses;
-- upstream's lspconfig.clangd.setup{} is the older one.
vim.lsp.config("clangd", {
  -- The default C++ standard, and the ONLY place it is set. fallbackFlags
  -- apply only when a file has no compile database, so a real project always
  -- wins: compile_commands.json (CMake) > this.
  --
  -- Do not move this into ~/Library/Preferences/clangd/config.yaml --
  -- CompileFlags.Add there appends *after* the compile command and would
  -- override CMake. That bug once pinned everything to c++20.
  --
  -- These flags are language-agnostic and clang rejects -std=c++23 on C, so
  -- that config.yaml strips it back off for .c files.
  init_options = {
    fallbackFlags = { "-std=c++23" },
  },

  on_attach = function(client, _)
    -- From upstream: the signature popup fights the completion menu.
    client.server_capabilities.signatureHelpProvider = false
  end,
})

vim.lsp.enable "clangd"

-- Future servers (pyright, ruff, ...) go here: vim.lsp.config(name, {...})
-- then vim.lsp.enable(name), plus the binary in mason-tool-installer's
-- ensure_installed. See :h vim.lsp.config
