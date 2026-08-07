require "nvchad.options"

-- add yours here!

-- Hybrid line numbers: absolute on the cursor line, relative above and below,
-- so the count for a j/k/dd motion can be read straight off the gutter.
-- NvChad sets `number` but leaves `relativenumber` off.
-- Toggle at runtime with <leader>rn (relative) and <leader>n (numbers).
vim.o.relativenumber = true

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
