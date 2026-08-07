require "nvchad.autocmds"

-- C/C++ indent width. NvChad sets shiftwidth/tabstop/softtabstop = 2 globally,
-- but ~/.clang-format uses IndentWidth: 4 -- so `o` produced a 2-space line and
-- format-on-save immediately rewrote it to 4. Keep the two in agreement.
--
-- Buffer-local (vim.bo), so Lua and everything else keep NvChad's 2 and stay
-- consistent with .stylua.toml (indent_width = 2).
--
-- A FileType autocmd rather than after/ftplugin/, so it runs after Neovim's
-- built-in ftplugin/cpp.vim and indent/cpp.vim and therefore wins.
--
-- If you change IndentWidth in ~/.clang-format, change it here too.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("CppIndent", { clear = true }),
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
    -- cindent is already on via Neovim's indent/cpp.vim. smartindent is the
    -- cruder fallback it supersedes, and NvChad turns it on globally.
    vim.bo.cindent = true
    vim.bo.smartindent = false
  end,
})
