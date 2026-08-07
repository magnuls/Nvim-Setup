return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- NvChad's cmp binds <CR>, <Tab>/<S-Tab>, <C-n>/<C-p>, <C-Space> and <C-e>,
  -- but not <C-y> -- so <C-y> fell through to Vim's built-in insert-mode
  -- "copy the character above the cursor" and appeared to do nothing.
  --
  -- Confirming is also what applies clangd's additionalTextEdits, which is how
  -- the #include gets added (see CONFIG-REFERENCE.md, "Auto-#include").
  --
  -- opts must be a FUNCTION that mutates the merged table: assigning a fresh
  -- `mapping` would discard everything NvChad set.
  -- nvim-tree binds `s` to api.node.run.system ("Run System"), which calls
  -- vim.ui.open() -> macOS `open` -> whatever app claims that file type. Restore
  -- the neo-tree meaning from the old config: s = vsplit, S = hsplit.
  -- <C-v>/<C-x>/<C-t> keep working; nvim-tree's `S` (search node) is the cost.
  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      -- NvChad ships `filters = { dotfiles = false }`, i.e. show them. Hide the
      -- clutter by default instead; both filters have built-in toggles.
      -- Merged, not assigned, so anything else under `filters` survives.
      opts.filters = vim.tbl_deep_extend("force", opts.filters or {}, {
        dotfiles = true, -- .git, .stylua.toml, ...   toggle with H
        git_ignored = true, -- build/, node_modules/, ... toggle with I
      })

      opts.on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        -- Defaults FIRST -- calling this after would reinstate s = Run System.
        api.config.mappings.default_on_attach(bufnr)

        local function o(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set("n", "s", api.node.open.vertical, o "Open: Vertical Split")
        vim.keymap.set("n", "S", api.node.open.horizontal, o "Open: Horizontal Split")
      end
      return opts
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      -- select = true accepts the highlighted entry without a prior <C-n>,
      -- matching the blink.cmp `default` preset the old config used.
      opts.mapping["<C-y>"] = cmp.mapping.confirm { select = true }
      return opts
    end,
  },

  -- nvim-treesitter's default branch is now `main`, a rewrite whose setup()
  -- accepts ONLY install_dir -- `ensure_installed` is silently ignored (both
  -- NvChad's and any of ours). Parsers must be installed with .install() and
  -- highlighting started per-buffer with vim.treesitter.start().
  --
  -- Neovim 0.12 bundles c, lua, markdown, query, vim and vimdoc, but NOT cpp,
  -- so without this C++ has no treesitter highlighting at all.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ts = require "nvim-treesitter"
      ts.setup {}

      local want = { "c", "cpp", "lua", "luadoc", "printf", "vim", "vimdoc" }
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

  -- Debugger. Keymaps live in lua/mappings.lua, not here -- the v2.0
  -- `require("core.utils").load_mappings("dap")` hook no longer exists.
  {
    "mfussenegger/nvim-dap",
  },

  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    -- nvim-nio became a hard dependency after dreamsofcode's config was
    -- written; without it dap-ui errors on load.
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {
        -- Default handler: keeps stock behaviour for every adapter but codelldb.
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,

        -- Replace mason-nvim-dap's prompt-every-time codelldb configs with ones
        -- that remember the last executable, so re-running (F5 + Enter) works
        -- like an IDE run configuration.
        codelldb = function(config)
          local dap = require "dap"
          local last_program

          local function pick_program()
            local program = vim.fn.input("Path to executable: ", last_program or (vim.fn.getcwd() .. "/"), "file")
            if program == nil or program == "" then
              return dap.ABORT
            end
            last_program = program
            return program
          end

          config.configurations = {
            {
              name = "LLDB: Launch",
              type = "codelldb",
              request = "launch",
              program = pick_program,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              args = {},
            },
            {
              name = "LLDB: Launch (with args)",
              type = "codelldb",
              request = "launch",
              program = pick_program,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              args = function()
                return vim.split(vim.fn.input "Args: ", " +", { trimempty = true })
              end,
            },
          }

          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },

  -- dreamsofcode put ensure_installed on mason.nvim itself. That worked under
  -- NvChad v2.0, whose :MasonInstallAll command read it. mason.nvim v2 has no
  -- such setting and NvChad v2.5 dropped the command, so that block installs
  -- nothing at all. mason-tool-installer is the mechanism that actually works
  -- (and is what the old kickstart config used).
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "codelldb",
        -- conform formats lua with stylua; without this it silently no-ops.
        "stylua",
      },
    },
  },

  -- Not in dreamsofcode's config. ~/.config/tmux/tmux.conf already loads the
  -- tmux half of this plugin; without the nvim half, <C-h/j/k/l> stops at the
  -- tmux pane border instead of crossing it.
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    -- The plugin's own <C-h/j/k/l> maps are set when it loads, which is before
    -- NvChad's `require "mappings"` runs in its startup vim.schedule -- so
    -- NvChad's plain <C-w>h window-switching silently overwrites them and the
    -- plugin does nothing. Disable its mappings and set them in mappings.lua
    -- instead, where they land after NvChad's.
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}
