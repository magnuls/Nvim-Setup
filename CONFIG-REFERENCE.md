# Neovim C++ Setup — Reference

Generated 2026-08-06.

- **Base:** [NvChad](https://github.com/NvChad/starter) v2.5 starter, plugins via **lazy.nvim**
- **C++ layer:** ported from [dreamsofcode-io/neovim-cpp](https://github.com/dreamsofcode-io/neovim-cpp)
- **Leader:** `<Space>` (set in `init.lua`)
- **Tmux:** `~/.config/tmux/tmux.conf`, plugins via **TPM**

> The upstream C++ repo targets NvChad **v2.0** (Feb 2024). Its file layout
> (`lua/custom/`), its APIs (`core.utils.load_mappings`, `plugins.configs.lspconfig`),
> and its formatter (`null-ls`, archived 2023) no longer exist. What follows is the
> ported equivalent, not a copy. Divergences are called out as they come up.

## Layout

```
init.lua                  NvChad bootstrap (stock, don't edit)
lua/
  chadrc.lua              theme / UI
  options.lua             global editor options
  autocmds.lua            per-filetype settings (C/C++ indent)
  mappings.lua            all keymaps -- runs last, so it wins
  plugins/
    cpp.lua               C/C++ specs: LSP -> format -> debug
    python.lua            Python debug adapter
    editor.lua            treesitter, file tree, completion, tmux
    git.lua               lazygit
    tools.lua             every external tool (mason-tool-installer)
  configs/
    lspconfig.lua         clangd (add future servers here)
    conform.lua           formatters
    dap.lua               debugger + codelldb run configs
    lazy.lua              lazy.nvim settings (stock)
```

Specs say *which* plugin and when to load it; `configs/` says how it behaves.
lazy.nvim imports every file in `plugins/`, so a new domain is a new file.

`test/` holds a smoke suite: `./test/smoke.sh` builds a polyglot fixture
(C++/C sharing `include/*.h`, CMake, a Python package with a `.venv`, git
history) and drives 107 behavioural checks against it, exiting non-zero on any
failure. Run it after changing anything.

Settings outside this repo that the config depends on:

| Path | Controls |
|---|---|
| `~/.clang-format` | C/C++ format style (`IndentWidth: 4`) |
| `~/Library/Preferences/clangd/config.yaml` | clangd flags, diagnostics |
| `~/.config/tmux/tmux.conf` | tmux keys, theme, plugins |

---

# Part 1 — Debugging

The seven keys below replace the upstream repo's `<leader>db` / `<leader>dr`.
They come from the previous kickstart config (`lua/kickstart/plugins/debug.lua`
at commit `6f9a367`, preserved in `~/.config/nvim.backup`).

> ⚠️ **`<leader>b` overrides NvChad's "new buffer".** Use `:enew` for a new buffer.
> Every other key here is unclaimed by NvChad.

| Key | Action |
|---|---|
| `<F5>` | Start / continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle DAP UI (see last session's result) |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint (prompts for the condition) |
| `<leader>dpr` | Debug the Python test method under the cursor (python only) |

**How a debug session runs.** Set a breakpoint, press `<F5>`, and codelldb asks
for the path to the executable. The DAP UI opens automatically when the session
initializes and closes when it terminates or exits — three `dap.listeners`
registered in `lua/plugins/init.lua`.

**The run-configuration behaviour.** Stock mason-nvim-dap prompts for the
executable path on *every* launch, starting from an empty box. A custom
`codelldb` handler replaces those configurations with ones that close over a
`last_program` local, so the second `<F5>` pre-fills the last path and `F5`+Enter
re-runs — the way an IDE run config behaves. There are two configurations:
`LLDB: Launch` and `LLDB: Launch (with args)`, the second prompting for
space-separated arguments. The sibling default handler leaves every other
adapter at stock behaviour.

**Verified working end to end** — the smoke suite drives a real session for both
languages: `<leader>b`, `<F5>`, stops at the breakpoint, `<F2>` steps, clean
terminate. Run `./test/smoke.sh debug` to re-check.

### ⚠️ Build with debug info, or breakpoints silently never bind

```bash
g++ -std=c++23 -g -o main main.cpp
```

With CMake, **an unset `CMAKE_BUILD_TYPE` passes no `-g` at all**:

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
```

The failure mode gives you nothing to go on: codelldb launches the program, it
runs to completion, and the breakpoint is simply ignored. No error, no warning.
Check with `dwarfdump --debug-info <binary> | head` — empty output means no
debug info. This cost real time to diagnose while writing the test suite.

### macOS: developer mode

`sudo DevToolsSecurity -enable` (already enabled here). Without it macOS blocks
`debugserver` from taking control of a process, and the symptom looks identical
to the missing-`-g` case above — session initializes, then nothing.

---

# Part 2 — Keybindings

Everything below is a NvChad default, read from
`~/.local/share/nvim/lazy/NvChad/lua/nvchad/mappings.lua` — so this documents
what is actually bound, not what the docs claim.

### Files & search (Telescope)
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fa` | Find all files (hidden + ignored) |
| `<leader>fw` | Live grep |
| `<leader>fz` | Fuzzy find in current buffer |
| `<leader>fd` | Diagnostics, project-wide and fuzzy-searchable — **added** |
| `<leader>fb` | Buffers |
| `<leader>fo` | Recent files |
| `<leader>fh` | Help pages |
| `<leader>ma` | Marks |
| `<leader>cm` | Git commits |
| `<leader>gt` | Git status |

### Git
| Key | Action |
|---|---|
| `<leader>gg` | **lazygit** — branches, log graph, staging, rebase, stash |
| `<leader>gf` | lazygit filtered to the current file's history |

gitsigns draws the signs but has **no keymaps** — NvChad ships it without an
`on_attach` and gitsigns binds nothing by default, so hunk staging, reset,
preview, blame and navigation are all unbound. `]c` / `[c` are Vim's diff-mode
motions and do not step gutter hunks. See CHEATSHEET.md → "Not bound".

lazygit is the external binary (`brew install lazygit`), opened in a floating
window by `kdheepak/lazygit.nvim`, lazy-loaded on command. gitsigns handles
hunk signs, staging and inline blame; Telescope handles commit/status pickers.
lazygit covers what neither does: branch management and a readable log graph.

### File tree
| Key | Action |
|---|---|
| `\` | Reveal current file in the tree / close it if already inside — **added**, matches the old neo-tree binding |
| `<C-n>` | Toggle nvim-tree |
| `<leader>e` | Focus nvim-tree |
| `s` | Open in **vertical split** — **overridden** (see below) |
| `S` | Open in **horizontal split** — **overridden** |
| `<C-v>` / `<C-x>` / `<C-t>` | Vertical split / horizontal split / new tab (nvim-tree defaults, still work) |
| `<CR>` / `o` | Open in the current window |
| `a` / `d` / `r` | Create / delete / rename |
| `H` | Toggle hidden **dotfiles** (hidden by default) |
| `I` | Toggle **git-ignored** files (hidden by default) |
| `g?` | Full nvim-tree keymap help |

Dotfiles and git-ignored files are hidden on open — NvChad ships
`filters = { dotfiles = false }` (i.e. *shown*); both are flipped to `true`
here. `H` and `I` bring them back for the session.

> **Why `s` was remapped.** nvim-tree binds `s` to `api.node.run.system`
> ("Run System"), which calls `vim.ui.open()` → macOS `open` → whatever
> application claims that file type. On this machine that meant pressing `s`
> launched **Shadowrocket**. neo-tree, used in the old config, binds `s` to
> vsplit and `S` to hsplit; those are restored here. The cost is nvim-tree's
> `S` (search node) — use `g?` to find alternatives.
>
> The override lives in `lua/plugins/editor.lua` and calls
> `api.map.on_attach.default(bufnr)` **first**, then rebinds. Reversing that
> order silently reinstates `s` = Run System. All 60 default tree mappings are
> preserved.

### Git markers in the tree (`✗`, `★`)
Not errors — nvim-tree's git status glyphs. `✗` unstaged, `★` untracked, `✓`
staged, `➜` renamed, `◌` ignored. A folder inherits the mark of its dirty
children. NvChad overrides only `unmerged`.

They appeared en masse at first because `~/.config/nvim` was still a **clone of
NvChad/starter**, so every customization read as a diff against upstream's
commit. It has since been re-initialised as a standalone repo
(`rm -rf .git && git init`), so the tree is clean. It now pushes to
`github.com/magnuls/Nvim-Setup`.

### Buffers & windows
| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close buffer |
| `<C-h/j/k/l>` | Move between splits — **and tmux panes**, see Part 5 |
| `<C-s>` | Save |
| `<C-c>` | Yank whole file |

### LSP
| Key | Action | Source |
|---|---|---|
| `gd` | Go to definition | NvChad |
| `gD` | Go to declaration | NvChad |
| `<leader>D` | Go to type definition | NvChad |
| `<leader>ra` | Rename (NvRenamer) | NvChad |
| `<leader>ds` | Diagnostics → loclist | NvChad |
| `<leader>wa` / `<leader>wr` / `<leader>wl` | Add / remove / list workspace folder | NvChad |
| `K` | Hover docs | Neovim built-in |
| `grr` | References | Neovim built-in |
| `gra` | Code action | Neovim built-in |
| `gri` | Implementation | Neovim built-in |
| `grn` | Rename | Neovim built-in |

### Terminals
| Key | Action |
|---|---|
| `<leader>h` | New horizontal terminal |
| `<leader>v` | New vertical terminal |
| `<A-i>` | Toggle floating terminal |
| `<A-h>` / `<A-v>` | Toggle horizontal / vertical terminal |
| `<C-x>` | Escape terminal mode |
| `<leader>pt` | Pick a hidden terminal |

### Completion (nvim-cmp, insert mode)
| Key | Action |
|---|---|
| `<C-y>` | **Accept** the highlighted item — **added**, matches the old blink.cmp `default` preset |
| `<CR>` | Accept (NvChad's default; both work) |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump snippet placeholders |
| `<C-Space>` | Open the menu |
| `<C-e>` | Close the menu |
| `<C-d>` / `<C-f>` | Scroll docs down / up |

NvChad binds no `<C-y>` of its own, so before this it fell through to Vim's
built-in insert-mode `<C-y>` ("copy the character above the cursor") — typing
`std::vec` and pressing it produced `std::veci`, which is what made it look
broken.

### Auto-`#include` on accept
Accepting a completion also adds the header the symbol needs. Type `std::vec`
in a file with no `<vector>` include, press `<C-y>`, and `#include <vector>`
appears at the top.

Nothing was configured to enable this — every piece already shipped:
- clangd's `--header-insertion` defaults to `iwyu`.
- NvChad's capabilities already declare
  `completionItem.resolveSupport.properties` including `additionalTextEdits`.
- clangd attaches the edit **directly to the completion item** (it reports
  `resolveProvider: false`, so there is no `completionItem/resolve` round-trip).
- nvim-cmp applies those edits on confirm — `lua/cmp/core.lua:440`.

The chain only ever runs on *confirm*, which is why an unbound `<C-y>` made the
feature look absent.

**The `•` prefix** on an item (`•vector`) is clangd's header-insertion
decorator: it marks completions that will add an `#include`. Items already in
scope have no dot. Disable with `--header-insertion-decorators=false` if you
find it noisy.

### Unused-include warnings — turned off
`Included header X is not used directly (fix available)` comes from
**include-cleaner**, which clangd enables **by default from v17 onward**. It is
not something this config switched on, and it is not a `-Wall`/`-Wextra`
warning.

It shows up here and not in the 2024 dreamsofcode video purely because Mason
installs the current clangd (**22.1.6**) while the video ran clangd ~17. Note
the video's own `main.cpp` carries the same stray `#include <iterator>` — both
setups auto-insert it identically; only the newer clangd reports it.

Disabled in `~/Library/Preferences/clangd/config.yaml`:

```yaml
Diagnostics:
  UnusedIncludes: None
```

`MissingIncludes` is left at its default — a different check, and unrelated to
header-insertion-on-completion, which still works.

Set `UnusedIncludes: Strict` to turn it back on; on real projects dead includes
are worth knowing about. clangd must be restarted to pick up a change
(`:LspRestart`).

The warning was always accurate, incidentally — `gra` (code action) deletes the
dead include in one keystroke if you would rather fix than silence.

### Misc
| Key | Action |
|---|---|
| `;` | Enter command mode (`:`) |
| `jk` (insert) | Escape |
| `<Esc>` | Clear search highlight |
| `<leader>/` | Toggle comment (normal + visual) |
| `<leader>fm` | Format buffer manually |
| `<leader>ch` | **NvCheatsheet** — every binding, live |
| `<leader>th` | Theme picker |
| `<leader>n` / `<leader>rn` | Toggle line / relative numbers |
| `<leader>wK` | Which-key: all keymaps |

`<leader>ch` is the in-editor version of this document and stays current
automatically — anything mapped with a `desc` shows up there, including the
seven debug keys above.

---

# Part 3 — Features

### Theme
`tokyonight` via `lua/chadrc.lua` (`M.base46.theme`) — **not** dreamsofcode's
catppuccin. Alacritty imports `themes/tokyo_night.toml` and tmux runs
`tokyo-night-tmux`, so any other nvim theme leaves the statusline visibly
clashing with the tmux bar directly beneath it. Verified: nvim's `Normal`
background is `#1a1b26`, the same value Alacritty uses.

Swap interactively with `<leader>th`.

> ⚠️ **Do not delete `~/.local/share/nvim/base46/` to force a theme rebuild.**
> `init.lua` line 29 runs `dofile(base46_cache .. "defaults")` before anything
> can regenerate it, so a missing cache aborts startup with a traceback and
> leaves you with no options, autocmds, or mappings. Use `<leader>th`, which
> handles the cache. If you have already deleted it, rebuild out-of-band:
>
> ```bash
> nvim --headless -u NONE -c "lua
> vim.g.base46_cache = vim.fn.stdpath('data') .. '/base46/'
> local d = vim.fn.stdpath('data') .. '/lazy/'
> for n in vim.fs.dir(d) do vim.opt.rtp:prepend(d .. n) end
> require('base46').load_all_highlights()" -c 'qa!'
> ```

### LSP — clangd
Configured in `lua/configs/lspconfig.lua` with `vim.lsp.config()` +
`vim.lsp.enable()`, the Neovim 0.11 mechanism NvChad v2.5 uses. The upstream
repo's `lspconfig.clangd.setup{}` is the older API.

Two settings:
- `signatureHelpProvider = false` — from upstream; the signature popup fights
  the completion menu.
- `init_options.fallbackFlags = { "-std=c++23" }` — see below.

### Which C++ standard clangd uses

Precedence, highest first:

1. **The project's `compile_commands.json`** — what CMake generates. A real
   project always controls its own standard.
2. **`-std=c++23`** from `init_options.fallbackFlags` in
   `lua/configs/lspconfig.lua`, used only when a file has **no** compile
   database (loose scratch files).

That is the whole chain. `~/Library/Preferences/clangd/config.yaml`
deliberately does **not** set `-std` — see the warning below for why.

**For CMake projects, declare the standard and the editor follows automatically:**

```cmake
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)   # writes build/compile_commands.json
```

clangd finds `compile_commands.json` in the project root or `build/` on its own
— no nvim configuration needed. Verified end to end: with
`CMAKE_CXX_STANDARD 17` clangd correctly flags `std::println` as missing; flip
to `23` and it goes clean.

So if clangd ever flags `std::println`, that now means **your build would reject
it too**. Fix the CMakeLists, not the editor.

### ⚠️ `CompileFlags.Add` is not a fallback mechanism

In `~/Library/Preferences/clangd/config.yaml`, `CompileFlags.Add` appends
*after* the compile command, and for `-std` the last flag wins. Anything put
there silently overrides `compile_commands.json`, `compile_flags.txt` **and**
`fallbackFlags`.

This caused two separate bugs before it was removed:
- A stale `-std=c++20` beat an explicit `-std=c++23` everywhere else, making
  valid C++23 look broken.
- `-std=c++23` was applied to C files too, and clang rejects it outright:
  `invalid argument '-std=c++23' not allowed with 'C'` — every `.c` file
  reported an error.

Both are fixed by keeping `-std` out of that file entirely. A `PathMatch`
fragment there still strips `-std=c++*` from `.c` files, because `fallbackFlags`
is language-agnostic and would otherwise reintroduce the C error on scratch C
files.

`.h` is deliberately left unforced: clangd infers a header's flags from the
source file that includes it, which is correct in a mixed C/C++ setup.

(`~/.config/clangd/config.yaml` also exists but is the *Linux* user-config path.
clangd never reads it on macOS.)

### Indentation — C/C++ is 4, everything else is 2
NvChad sets `shiftwidth`/`tabstop`/`softtabstop` to **2** globally, but
`~/.clang-format` uses `IndentWidth: 4`. Left alone, pressing `o` produced a
2-space line that format-on-save immediately rewrote to 4 — the editor and the
formatter disagreeing on every new line.

A `FileType` autocmd in `lua/autocmds.lua` sets **4** for `c`, `cpp`, `objc`,
`objcpp` and `cuda`, and turns `smartindent` off (`cindent`, already enabled by
Neovim's own `indent/cpp.vim`, supersedes it).

It is buffer-local and deliberately **not** global: `.stylua.toml` uses
`indent_width = 2`, so a global 4 would recreate the same mismatch in Lua files.

> **These two numbers must be changed together.** `IndentWidth` in
> `~/.clang-format` and `shiftwidth` in the `CppIndent` autocmd. Change one
> alone and the old symptom comes straight back.

### Brace style
`BreakBeforeBraces: Attach` — K&R, opening brace on the same line. What LLVM,
Google, and most C++ codebases use. Allman is the only other style still in
common circulation; GNU, Whitesmiths, Horstmann, Ratliff and Lisp style are
effectively extinct in modern C++.

### CMake
`neocmakelsp` (Mason) provides completion, hover, go-to-definition and
diagnostics for `CMakeLists.txt` and `*.cmake`. nvim-lspconfig ships the config,
so `lua/configs/lspconfig.lua` only calls `vim.lsp.enable "neocmake"`.

The diagnostics *are* the linting — grammar and semantic errors are reported
directly by the server, so there is no separate linter process.

`gersemi` formats on save via conform. Highlighting comes from the `cmake`
treesitter parser.

Note completion only works because NvChad's `*` capabilities advertise
`snippetSupport`; neocmakelsp returns nothing without it.

**CMakeLists is what feeds clangd its C++ standard** — see "Which C++ standard
clangd uses" above. Getting `CMAKE_CXX_STANDARD` right fixes editor diagnostics
and the build in one place.

### Python
Ported from [dreamsofcode-io/neovim-python](https://github.com/dreamsofcode-io/neovim-python)
(NvChad v2.0, Apr 2024). Most of that repo was already present — its DAP stack
came with the C++ port and conform replaces its null-ls — so the only new plugin
is `nvim-dap-python`.

| Tool | Role |
|---|---|
| `pyright` | types, completion, go-to-definition |
| `ruff` | linting and import sorting |
| `black` | formatting on save |
| `debugpy` | debugging, via `nvim-dap-python` |

The debug keys are the same as C++ (`<F5>`, `<leader>b`, …), plus
`<leader>dpr` to debug the test method under the cursor.

**`.venv` detection.** pyright is pointed at a project-local `.venv` so
pip-installed imports resolve. Two non-obvious requirements, both found the hard
way:
- `venvPath` must be **absolute**. A relative `"."` — which the old kickstart
  config used — silently fails over LSP even when `root_dir` is set. It is
  computed at attach in `configs/lspconfig.lua`.
- pyright resolves the venv once at startup, so setting `client.settings` is
  not enough; it needs an explicit `workspace/didChangeConfiguration`. Without
  that notification the absolute path is still ignored.

Verified against a project whose only copy of a package lived in `.venv`:
unresolved-import error before, zero diagnostics after.

**Divergences from upstream:**
- `ruff-lsp` → **`ruff`**. Mason no longer carries `ruff-lsp` (only `ruff`,
  `sqruff`, `trufflehog`), so upstream's choice is uninstallable. `ruff` is the
  Rust server that replaced it, same feature set.
- **mypy dropped.** Upstream runs it through null-ls for type errors; pyright
  already reports those, and adding mypy would mean a second diagnostics plugin
  and two type checkers disagreeing. Confirmed pyright catches what mypy would:
  passing `42` to a `str` parameter is flagged.
- `:TSInstall python` from upstream's README is unnecessary — parsers install
  automatically.

### Formatting
`conform.nvim` with `clang_format` for `c`/`cpp`, `gersemi` for `cmake`,
`black` for `python`, `stylua` for `lua`.

`timeout_ms` is **2000**, not conform's default 500. `black` and `gersemi` are
Python programs whose first run in a session pays interpreter startup and
bytecode compilation — measured ~210ms cold against ~70ms warm, but a cold miss
means the save silently goes unformatted. It is a ceiling, not a delay; fast
formatters are unaffected.
`format_on_save` is on (500 ms timeout, LSP fallback), so writing a buffer
reformats it. `<leader>fm` formats on demand.

This replaces upstream's `configs/null-ls.lua`, which built the same behaviour
by hand out of a `BufWritePre` autocmd and an augroup. `jose-elias-alvarez/null-ls`
was archived in Aug 2023; conform ships with NvChad already, so the port drops a
dependency rather than adding one.

**Style** comes from `~/.clang-format`: LLVM base, 4-space indent, no tabs,
100-column limit, `Standard: Latest`. It lives at `$HOME` because clang-format
walks up parent directories — so it is the default for everything under `~`,
while any project with its own `.clang-format` overrides it.

(`Standard: Latest`, not `c++23` — clang-format's enum stops at `c++20` and
rejects `c++23` as unknown.)

### Tool installation
`mason-tool-installer` installs `clangd`, `clang-format`, and `codelldb` on
startup.

Upstream put `ensure_installed` on `mason.nvim` itself. That worked under NvChad
v2.0, whose `:MasonInstallAll` command read the field — but **mason.nvim v2 has
no `ensure_installed` setting** and NvChad v2.5 dropped the command, so that
block installs nothing and fails silently. mason-tool-installer is what actually
works, and is what the old kickstart config used.

Mason's binaries live in its own directory, not on your shell `PATH` — `clang-format`
being absent from `which clang-format` is expected and does not affect conform.

### Treesitter
Installs `c`, `cpp`, `lua`, `luadoc`, `printf`, `vim`, `vimdoc` into
`~/.local/share/nvim/site/parser/`. Building them needs `tree-sitter-cli`
(present, via Homebrew).

**Why the spec looks unusual.** nvim-treesitter's default branch is now `main`,
a rewrite whose `setup()` accepts *only* `install_dir` — **`ensure_installed` is
silently ignored**, including NvChad's own. The stock config therefore installs
zero parsers and nothing warns you. Neovim 0.12 bundles `c`, `lua`, `markdown`,
`query`, `vim` and `vimdoc`, but **not `cpp`**, so C++ ends up with no
treesitter highlighting whatsoever.

The config works around this by calling `require("nvim-treesitter").install()`
directly for anything missing, and starting highlighting per-buffer from a
`FileType` autocmd via `vim.treesitter.start()` — the two things the `main` API
requires you to do yourself.

### ⚠️ Keymap ordering: NvChad wins by default
`init.lua` runs `require "mappings"` inside a `vim.schedule`, which fires *after*
eagerly-loaded plugins have set their own keymaps. So a plugin that maps
`<C-h>` at load time gets silently overwritten by `nvchad.mappings`.

This bit vim-tmux-navigator: installed, loaded, and completely inert, with
`<C-h>` still doing a plain `<C-w>h` that stops at the tmux pane border. The fix
is `vim.g.tmux_navigator_no_mappings = 1` plus explicit maps in
`lua/mappings.lua`, which run last and therefore win.

Anything you want to beat a NvChad default belongs in `lua/mappings.lua`, after
the `require "nvchad.mappings"` line.

---

# Part 3b — External requirements

### ✅ ripgrep — installed
Required by Telescope's `live_grep` (`<leader>fw`), which refuses to run without
it. Now at `/opt/homebrew/bin/rg`; live grep verified working.

### ✅ Developer mode — enabled
Required for `debugserver` to attach. See Part 1.

### Optional: `fd`
Not installed. Telescope's file pickers are faster with it (`brew install fd`).

### Optional: tmux focus-events
`:checkhealth` notes `focus-events` is not enabled, which can stop `'autoread'`
from noticing files changed outside nvim. Add to `~/.config/tmux/tmux.conf`:

```tmux
set -g focus-events on
```

---

# Part 4 — The richer clangd flags (not enabled)

The previous config ran clangd with considerably more. None of it is active —
this section records what each flag bought, so enabling it later is an informed
choice rather than cargo cult.

| Flag | What it does |
|---|---|
| `--clang-tidy` | Runs clang-tidy checks as you type. Surfaces bug-prone patterns plain clangd never reports: use-after-move, missing `override`, implicit narrowing, ignored `[[nodiscard]]`. The single biggest quality upgrade of the set. |
| `--background-index` | Indexes the whole project on a background thread. Without it, "find references" and rename only see files you currently have open — silently incomplete results on a large codebase. |
| `--header-insertion=iwyu` | Completing a symbol auto-adds its `#include`. |
| `--completion-style=detailed` | Full signatures in the completion menu instead of bare names. Matters for overload sets. |

Plus a `before_init` hook injecting absolute include paths:

```lua
before_init = function(params, config)
  local fallback_flags = { "-std=c++23", "-Wall", "-Wextra" }
  if config.root_dir then
    table.insert(fallback_flags, "-I" .. config.root_dir .. "/include")
    table.insert(fallback_flags, "-I" .. config.root_dir .. "/src")
  end
  params.initializationOptions = vim.tbl_deep_extend("force",
    params.initializationOptions or {}, { fallbackFlags = fallback_flags })
end
```

**The problem this solved:** in a project with no `compile_commands.json`,
clangd resolves relative include paths against *each source file's own
directory*. So `#include "foo/bar.hpp"` resolves from `src/a/b/` and fails for
anything nested. Absolute `-I` paths computed from the project root fix it.
Irrelevant once you have a CMake-generated compile database.

> Note: `before_init`, not `on_new_config`. The latter was a legacy
> nvim-lspconfig hook and is **never called** by the native `vim.lsp.config()`
> path — a silent no-op.

To enable, add the `cmd` and `before_init` fields to the `vim.lsp.config("clangd", …)`
table in `lua/configs/lspconfig.lua`:

```lua
cmd = {
  "clangd",
  "--clang-tidy",
  "--background-index",
  "--header-insertion=iwyu",
  "--completion-style=detailed",
},
```

---

# Part 5 — Tmux (`~/.config/tmux/tmux.conf`)

Prefix is the default `Ctrl-b`.

| Key | Action |
|---|---|
| `prefix \|` | Split vertically (side by side) |
| `prefix -` | Split horizontally (stacked) |
| `prefix r` | Reload the config |
| `prefix h/j/k/l` | Resize pane by 5, repeatable |
| `prefix m` | Toggle pane zoom, repeatable |
| `Ctrl-h/j/k/l` | Navigate panes **and nvim splits** — no prefix |
| `v` / `C-v` / `y` (copy mode) | Begin selection / rectangle toggle / copy and cancel |

Windows and panes are 1-indexed with `renumber-windows on`. Mouse is enabled.
`default-terminal` is `tmux-256color` with `Tc` overrides, without which nvim
colorschemes render washed out.

**Plugins (TPM):** vim-tmux-navigator, tmux-resurrect (with pane-contents
capture), tmux-continuum (auto-save every 15 min, auto-restore on), and
tokyo-night-tmux for the status bar.

### The vim-tmux-navigator pairing
This plugin has to be installed on **both** sides to work. Tmux already had it;
the Neovim half was added to `lua/plugins/init.lua` as part of this setup. With
only one side, `Ctrl-h/j/k/l` moves between nvim splits but stops dead at the
tmux pane border. With both, one keystroke crosses the boundary in either
direction.

Note this claims `Ctrl-h/j/k/l`, which is why tmux pane *resizing* is on
`prefix h/j/k/l` instead.

---

# Divergences from dreamsofcode-io/neovim-cpp

| Upstream | Here | Why |
|---|---|---|
| `lua/custom/**` layout | v2.5 layout (`lua/plugins/`, `lua/configs/`) | v2.0 directory no longer read |
| `M.plugins = "custom.plugins"`, `M.mappings = …` | removed | Dead keys in v2.5 chadrc |
| `require("core.utils").load_mappings("dap")` | keys in `lua/mappings.lua` | API removed |
| `lspconfig.clangd.setup{}` | `vim.lsp.config` + `vim.lsp.enable` | Pre-0.11 API |
| `null-ls` + manual `BufWritePre` autocmd | `conform.nvim` `format_on_save` | null-ls archived 2023 |
| `ensure_installed` on `mason.nvim` | `mason-tool-installer` | Silently installs nothing in v2 |
| `<leader>db` / `<leader>dr` | `<leader>b` / `<F5>` + 5 more | Old kickstart bindings |
| dap-ui without `nvim-nio` | `nvim-nio` added | Became a hard dependency |
| — | `-std=c++23` fallbackFlags | Requested |
| — | `~/.clang-format` | Requested |
| — | `vim-tmux-navigator` | Tmux half already installed |
| — | treesitter `c` / `cpp` | Starter ships it commented out |
