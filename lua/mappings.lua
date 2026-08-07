require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- File tree on <\>, as in the old kickstart/neo-tree config. NvChad only binds
-- <C-n> (toggle) and <leader>e (focus); <\> is unmapped by default.
-- Focuses the tree when outside it, closes it when already inside -- the
-- reveal/close behaviour neo-tree had.
map("n", "\\", function()
  local api = require "nvim-tree.api"
  if vim.bo.filetype == "NvimTree" then
    api.tree.close()
  else
    api.tree.find_file { open = true, focus = true }
  end
end, { desc = "nvimtree reveal / close" })

-- Cross nvim splits and tmux panes with one keystroke. These must be set here,
-- after `require "nvchad.mappings"` above, or NvChad's plain <C-w>h window
-- switching wins and movement stops at the tmux pane border.
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "window/pane left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "window/pane down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "window/pane up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "window/pane right" })

-- Debugger. These replace dreamsofcode's <leader>db / <leader>dr with the
-- bindings from the old kickstart config (lua/kickstart/plugins/debug.lua).
--
-- dap/dapui are required inside each callback, not at the top of the file:
-- mappings.lua runs in a vim.schedule at startup, before the VeryLazy plugins
-- have loaded.
--
-- NOTE: <leader>b overrides NvChad's "new buffer". Use :enew for that.
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })

map("n", "<F1>", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

map("n", "<F2>", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

map("n", "<F3>", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

map("n", "<F7>", function()
  require("dapui").toggle()
end, { desc = "Debug: See last session result" })

map("n", "<leader>b", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

map("n", "<leader>B", function()
  require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "Debug: Set Conditional Breakpoint" })
