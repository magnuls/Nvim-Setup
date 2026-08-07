-- Keymaps. Leader is <Space> (set in init.lua).
--
-- Anything here overrides NvChad, because this file runs last. Conversely, a
-- plugin that maps keys at load time WILL be overwritten by nvchad.mappings
-- below -- set those here instead (see the tmux block).
--
-- Full key list, including NvChad's own: CONFIG-REFERENCE.md, or <leader>ch.

require "nvchad.mappings"

local map = vim.keymap.set

-- General ---------------------------------------------------------------------
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- File tree -------------------------------------------------------------------
-- <\> reveals the current file, or closes the tree from inside it, as neo-tree
-- did. NvChad binds only <C-n> and <leader>e.
map("n", "\\", function()
  local api = require "nvim-tree.api"
  if vim.bo.filetype == "NvimTree" then
    api.tree.close()
  else
    api.tree.find_file { open = true, focus = true }
  end
end, { desc = "nvimtree reveal / close" })

-- Git ---------------------------------------------------------------------------
-- gitsigns (hunks, blame) and Telescope (<leader>cm commits, <leader>gt status)
-- are NvChad defaults. lazygit adds branches, log graph and rebasing.
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
map("n", "<leader>gf", "<cmd>LazyGitFilterCurrentFile<CR>", { desc = "LazyGit: current file history" })

-- Windows and tmux panes -------------------------------------------------------
-- Must be set here, after nvchad.mappings: otherwise NvChad's plain <C-w>h
-- wins and movement stops dead at the tmux pane border.
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "window/pane left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "window/pane down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "window/pane up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "window/pane right" })

-- Debugger ---------------------------------------------------------------------
-- From the old kickstart config. dap/dapui are required inside each callback,
-- not at the top: this file runs in a vim.schedule at startup, before the
-- VeryLazy plugins exist.
--
-- <leader>b overrides NvChad's "new buffer" -- use :enew for that.
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
