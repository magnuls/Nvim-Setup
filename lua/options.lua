-- Editor options. Global only -- per-filetype settings live in autocmds.lua.

require "nvchad.options"

-- Hybrid line numbers: absolute on the cursor line, relative above and below,
-- so the count for a j/k/dd motion is readable straight off the gutter.
-- NvChad sets `number` but leaves `relativenumber` off.
-- Toggle: <leader>rn (relative), <leader>n (numbers).
vim.o.relativenumber = true

-- Folding ----------------------------------------------------------------------
-- Fold boundaries come from the treesitter tree, but via nvim-ufo
-- (plugins/editor.lua), not foldmethod=expr. With expr, every reparse after an
-- edit rebuilds the folds and rebuilt folds forget their manual open/closed
-- state -- so a fold you closed with za pops open the moment you leave insert
-- mode. ufo computes the same treesitter boundaries, feeds them in as manual
-- folds, and carries their state across edits. foldmethod therefore stays at
-- Neovim's default, manual; ufo owns it.

-- Open everything on load. Without this a file arrives fully collapsed, which
-- no other editor does. 99 is the idiom for "deeper than any real nesting";
-- ufo additionally requires it, because it never moves foldlevel and instead
-- implements zM/zR itself (see mappings.lua).
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- The clickable gutter: foldcolumn draws the -/+ markers, and NvChad already
-- sets mouse=a, so clicking one toggles that fold.
vim.o.foldcolumn = "1"

-- ufo renders folded lines itself (syntax-highlighted, with a fold marker).
-- Empty foldtext (0.10+) is the matching fallback for any buffer ufo has not
-- attached to: the folded line stays highlighted instead of being replaced
-- with the plain "+--  12 lines:" filler.
vim.o.foldtext = ""
