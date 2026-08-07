-- Replaces dreamsofcode's configs/null-ls.lua. null-ls was archived in 2023;
-- conform (which NvChad already installs) does the same job in three lines.
-- Style comes from ~/.clang-format.
local options = {
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    lua = { "stylua" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
