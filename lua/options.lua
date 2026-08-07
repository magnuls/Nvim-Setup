-- Editor options. Global only -- per-filetype settings live in autocmds.lua.

require "nvchad.options"

-- Hybrid line numbers: absolute on the cursor line, relative above and below,
-- so the count for a j/k/dd motion is readable straight off the gutter.
-- NvChad sets `number` but leaves `relativenumber` off.
-- Toggle: <leader>rn (relative), <leader>n (numbers).
vim.o.relativenumber = true
