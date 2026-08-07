-- Editing experience: syntax, file tree, completion, window navigation.
-- None of this is C++-specific; the C/C++ toolchain lives in cpp.lua.

return {
  -- Syntax / parsers -------------------------------------------------------
  -- nvim-treesitter's default branch is now `main`, a rewrite whose setup()
  -- takes ONLY install_dir -- `ensure_installed` is silently ignored, NvChad's
  -- included, so the stock config installs zero parsers. Neovim 0.12 bundles
  -- c/lua/markdown/query/vim/vimdoc but NOT cpp, so C++ gets no highlighting
  -- at all. Hence the explicit install() + vim.treesitter.start() below.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ts = require "nvim-treesitter"
      ts.setup {}

      local want = { "c", "cpp", "cmake", "python", "lua", "luadoc", "printf", "vim", "vimdoc" }
      local installed = ts.get_installed "parsers"
      local missing = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, want)
      if #missing > 0 then
        ts.install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TSStart", { clear = true }),
        pattern = want,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- File tree --------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      -- NvChad ships dotfiles = false, i.e. *show* them. Hide the clutter;
      -- H toggles dotfiles, I toggles git-ignored.
      opts.filters = vim.tbl_deep_extend("force", opts.filters or {}, {
        dotfiles = true,
        git_ignored = true,
      })

      -- nvim-tree binds `s` to "Run System", which shells out to `open` and
      -- launches a Mac app. Restore neo-tree's meaning: s = vsplit, S = hsplit.
      opts.on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        -- Defaults FIRST; calling this after would undo the overrides.
        api.map.on_attach.default(bufnr)

        local function o(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "s", api.node.open.vertical, o "Open: Vertical Split")
        vim.keymap.set("n", "S", api.node.open.horizontal, o "Open: Horizontal Split")
      end
      return opts
    end,
  },

  -- Completion -------------------------------------------------------------
  -- NvChad binds <CR> but not <C-y>, so <C-y> fell through to Vim's builtin
  -- "copy char from line above". Confirming is also what applies clangd's
  -- additionalTextEdits, i.e. the auto-#include.
  --
  -- opts must be a FUNCTION mutating the merged table; assigning a fresh
  -- `mapping` would discard <Tab>, <CR> and the rest.
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.mapping["<C-y>"] = cmp.mapping.confirm { select = true }
      return opts
    end,
  },

  -- Window / tmux navigation -----------------------------------------------
  -- Its own <C-h/j/k/l> maps are set at load time, before NvChad's
  -- vim.schedule'd mappings.lua -- which would then overwrite them. Disable
  -- them here and set them in mappings.lua, where they land last.
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
