-- Formatters. Spec: plugins/cpp.lua.
-- Replaces upstream's null-ls (archived 2023); conform ships with NvChad.
--
-- C/C++ style comes from ~/.clang-format (LLVM base, IndentWidth 4).
-- Lua style comes from .stylua.toml in this repo.
--
-- Editor indent must match the formatter or every new line gets rewritten on
-- save -- see the CppIndent autocmd in lua/autocmds.lua.

return {
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "gersemi" },
    lua = { "stylua" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}
