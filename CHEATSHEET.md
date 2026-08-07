# Cheat Sheet

Every key actually bound in this config, most-used first, then by feature.

`<leader>` is `<Space>`. Sources are marked where it matters:
**[me]** this config, **[NvChad]**, **[nvim]** Neovim built-in, **[plugin]**.

Read from the live editor (`nvim_get_keymap` on a running instance) plus the
NvChad, gitsigns and lazygit sources — not from docs. Rationale for the
non-obvious choices is in CONFIG-REFERENCE.md; this file is the lookup table.

In-editor equivalent: `<leader>ch` (NvCheatsheet) or `<leader>wK` (which-key).

---

## The daily twenty

| Key | Does |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep the project |
| `<leader>fo` | Recent files |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close buffer |
| `\` | Reveal current file in tree / close tree |
| `<C-h/j/k/l>` | Move between splits **and tmux panes** |
| `<C-s>` | Save |
| `;` | `:` — command mode |
| `jk` | Escape (insert mode) |
| `<Esc>` | Clear search highlight |
| `gd` | Go to definition |
| `K` | Hover docs |
| `gra` | Code action |
| `grn` | Rename symbol |
| `grr` | References |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>/` | Toggle comment (normal + visual) |
| `<leader>gg` | lazygit |
| `<F5>` | Debug: start / continue |

---

## Files & search — Telescope

| Key | Does |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fa` | Find all files — includes hidden and git-ignored |
| `<leader>fw` | Live grep (ripgrep) |
| `<leader>fz` | Fuzzy find inside the current buffer |
| `<leader>fd` | Diagnostics across the whole project, fuzzy-searchable |
| `<leader>fb` | Open buffers |
| `<leader>fo` | Recent files |
| `<leader>fh` | Help pages |
| `<leader>ma` | Marks |
| `<leader>pt` | Pick a hidden terminal |
| `<leader>th` | Theme picker |

**Inside a Telescope window** — [plugin] defaults:

| Key | Does |
|---|---|
| `<C-n>` / `<C-p>` | Next / previous result |
| `<CR>` | Open |
| `<C-v>` / `<C-x>` / `<C-t>` | Open in vsplit / split / tab |
| `<C-u>` / `<C-d>` | Scroll the preview |
| `<C-q>` | Send results to quickfix (then `]q` / `[q` to walk them) |
| `<Esc>` | Close (Telescope's normal mode is `<C-c>`-free) |
| `?` | Show all picker mappings |

---

## Git — inside Neovim

Thin on purpose: lazygit does the heavy lifting.

| Key | Does | Source |
|---|---|---|
| `<leader>gg` | **lazygit** — full TUI: branches, log graph, staging, rebase, stash | [me] |
| `<leader>gf` | lazygit filtered to the current file's history | [me] |
| `<leader>cm` | Telescope: git commits | [NvChad] |
| `<leader>gt` | Telescope: git status | [NvChad] |

> **gitsigns has no keybindings.** The signs in the gutter are live (add,
> change, delete, changedelete), but NvChad ships gitsigns with no `on_attach`,
> and gitsigns sets no defaults of its own — so there is no hunk-stage,
> hunk-reset, hunk-navigate or blame key bound anywhere. Everything hunk-level
> goes through `<leader>gg`. See "Not bound" at the bottom for the fix.
>
> `]c` / `[c` do work, but they are Vim's built-in diff-mode motions — real
> only inside `:diffthis` / `nvim -d`, not against gutter signs.

---

## Git — inside lazygit (`<leader>gg`)

lazygit 0.64. `?` opens the context menu for whatever panel you are in — the
authoritative list. Panels: **1** status, **2** files, **3** branches,
**4** commits, **5** stash.

### Anywhere

| Key | Does |
|---|---|
| `q` | Quit (back to nvim) |
| `<Esc>` | Back / cancel |
| `?` | Menu of every key valid right here |
| `1`–`5` | Jump to panel |
| `<Tab>` / `h` `l` / `←` `→` | Cycle panels |
| `j` `k` / `↑` `↓` | Move |
| `/` | Search, `n` / `N` to step matches |
| `<Space>` | Select / toggle |
| `<CR>` | Confirm / drill in |
| `p` / `P` | Pull / push |
| `f` | Fetch |
| `R` | Refresh |
| `z` / `Z` | Undo / redo (reflog-based) |
| `+` / `_` | Grow / shrink the panel layout |
| `<C-u>` / `<C-d>` | Scroll the main (diff) view |
| `x` | Confirm discard |
| `@` | Extras menu (command log) |
| `:` | Run a raw shell command |

### Files panel (2)

| Key | Does |
|---|---|
| `<Space>` | Stage / unstage the file |
| `a` | Stage / unstage **everything** |
| `<CR>` | Drill into the file to stage individual hunks |
| `c` | Commit |
| `C` | Commit in `$EDITOR` |
| `A` | Amend the last commit |
| `w` | Commit skipping pre-commit hooks |
| `d` | Discard changes (menu) |
| `D` | Reset options — soft / mixed / hard |
| `s` | Stash all changes |
| `S` | Stash options menu |
| `i` | Add to `.gitignore` |
| `e` | Edit the file in `$EDITOR` |
| `` ` `` | Flat list ⇄ tree view |
| `-` / `=` | Collapse / expand all |

### Staging individual hunks (`<CR>` on a file)

| Key | Does |
|---|---|
| `<Space>` | Stage the hunk / selected lines |
| `h` / `l` or `←` / `→` | Previous / next hunk |
| `v` | Line-range select, then `<Space>` to stage just those lines |
| `a` | Toggle select-whole-hunk |
| `E` | Edit the hunk by hand |
| `d` | Discard the hunk |
| `<Esc>` | Back to the file list |

### Branches panel (3)

| Key | Does |
|---|---|
| `<Space>` | Checkout |
| `n` | New branch |
| `c` | Checkout by name (accepts a commit-ish) |
| `-` | Checkout the previous branch |
| `d` | Delete |
| `r` | Rebase the checked-out branch onto this one |
| `M` | Merge into the current branch |
| `f` | Fast-forward from upstream |
| `R` | Rename |
| `u` | Set upstream |
| `T` | Create tag |
| `o` | Create a pull request |
| `G` | Open the PR in a browser |
| `w` | New worktree |

### Commits panel (4)

| Key | Does |
|---|---|
| `<CR>` | Show the commit's files |
| `s` | Squash down into the commit below |
| `f` | Fixup — squash without keeping the message |
| `r` / `R` | Reword (inline / in `$EDITOR`) |
| `i` | Start an interactive rebase from here |
| `d` | Drop the commit |
| `e` | Mark for edit during rebase |
| `p` | Pick |
| `t` | Revert |
| `A` | Amend this commit with the staged changes |
| `g` | Reset to this commit (soft / mixed / hard) |
| `<C-j>` / `<C-k>` | Move the commit down / up |
| `C` / `V` | Cherry-pick copy / paste |
| `b` | Bisect |
| `T` | Tag this commit |
| `y` | Copy commit attribute (sha, message, URL…) |
| `o` | Open in browser |

### Stash panel (5)

| Key | Does |
|---|---|
| `<Space>` | Apply |
| `g` | Pop |
| `d` | Drop |
| `n` | New stash from current changes |
| `r` | Rename |

---

## Code — LSP

Buffer-local; live only once a language server attaches (clangd, pyright,
ruff, neocmake, lua_ls).

| Key | Does | Source |
|---|---|---|
| `gd` | Go to definition | [NvChad] |
| `gD` | Go to declaration | [NvChad] |
| `K` | Hover docs | [nvim] |
| `grr` | References | [nvim] |
| `gra` | Code action — also the one-key fix for a dead `#include` | [nvim] |
| `grn` | Rename symbol | [nvim] |
| `gri` | Implementation | [nvim] |
| `grt` | Type definition | [nvim] |
| `grx` | Run code lens | [nvim] |
| `gO` | Document symbols | [nvim] |
| `<C-s>` (insert/visual) | Signature help — **off for clangd**, it fought the completion menu | [nvim] |
| `<leader>D` | Type definition (NvChad's older alias for `grt`) | [NvChad] |
| `<leader>ra` | Rename via NvRenamer's floating box | [NvChad] |
| `<leader>ds` | Send diagnostics to the location list (this file) | [NvChad] |
| `<leader>fd` | Telescope diagnostics picker (whole project) | [custom] |
| `<leader>wa` / `<leader>wr` / `<leader>wl` | Add / remove / list workspace folder | [NvChad] |
| `<C-w>d` | Show the diagnostic under the cursor in a float | [nvim] |

---

## Diagnostics & list navigation

Neovim 0.11+ bracket pairs. All [nvim].

| Key | Does |
|---|---|
| `]d` / `[d` | Next / previous diagnostic |
| `]D` / `[D` | Last / first diagnostic in the buffer |
| `]q` / `[q` | Next / previous quickfix entry |
| `]Q` / `[Q` | Last / first quickfix entry |
| `]l` / `[l` | Next / previous location-list entry |
| `]b` / `[b` | Next / previous buffer (`:bnext`) |
| `]a` / `[a` | Next / previous arglist file |
| `]t` / `[t` | Next / previous tag |
| `]<Space>` / `[<Space>` | Insert a blank line below / above |

---

## Debugging — nvim-dap

All [me]. Needs `sudo DevToolsSecurity -enable` on macOS or the session starts,
verifies the breakpoint, and then does nothing.

| Key | Does |
|---|---|
| `<F5>` | Start / continue — first run prompts for the executable, then remembers it |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle the dap-ui panels |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint (prompts) |
| `<leader>dpr` | Python only: debug the test method under the cursor |

The UI opens with the session and closes when it ends. Two configurations:
**LLDB: Launch** and **LLDB: Launch (with args)**.

**Inside the dap-ui windows** [plugin]: `<CR>` expand / edit value, `e` edit,
`d` remove, `r` REPL, `<C-w>` between panels like any split.

---

## File tree — nvim-tree

| Key | Does | Source |
|---|---|---|
| `\` | Reveal the current file — or close the tree if you are in it | [me] |
| `<C-n>` | Toggle | [NvChad] |
| `<leader>e` | Focus | [NvChad] |
| `s` | Open in **vertical** split — **overridden** | [me] |
| `S` | Open in **horizontal** split — **overridden** | [me] |
| `<CR>` / `o` | Open |  |
| `<C-v>` / `<C-x>` / `<C-t>` | vsplit / split / new tab |  |
| `a` / `d` / `r` | Create / delete / rename |  |
| `x` / `c` / `p` | Cut / copy / paste |  |
| `y` / `Y` / `gy` | Copy name / relative path / absolute path |  |
| `H` | Show dotfiles (hidden by default) | [me] |
| `I` | Show git-ignored files (hidden by default) | [me] |
| `R` | Refresh |  |
| `E` / `W` | Expand all / collapse all |  |
| `-` | Up a directory |  |
| `g?` | **Full tree keymap list** — all ~60 |  |

> `s` and `S` are remapped because nvim-tree binds `s` to "Run System", which
> shells out to macOS `open` — pressing it launched Shadowrocket. neo-tree's
> meaning (vsplit / hsplit) is restored. The cost is nvim-tree's `S`
> (search node).

**Gutter glyphs** — git status, not errors: `✗` unstaged, `★` untracked,
`✓` staged, `➜` renamed, `◌` ignored. A folder inherits its dirty children's mark.

---

## Buffers, windows, tmux

| Key | Does | Source |
|---|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous buffer | [NvChad] |
| `<leader>x` | Close buffer | [NvChad] |
| `<C-h/j/k/l>` | Move between splits — **and across tmux pane borders** | [me] |
| `<C-s>` | Save | [NvChad] |
| `<C-c>` | Yank the whole file | [NvChad] |
| `<C-w>v` / `<C-w>s` | Split vertical / horizontal | [nvim] |
| `<C-w>q` | Close window | [nvim] |
| `<C-w>=` | Equalize sizes | [nvim] |

`<C-h/j/k/l>` go through vim-tmux-navigator, so the same four keys keep moving
once you hit the edge of Neovim and cross into the next tmux pane. Requires the
matching binding in `~/.config/tmux/tmux.conf`.

---

## Terminals

| Key | Does |
|---|---|
| `<A-i>` | Toggle floating terminal |
| `<A-h>` / `<A-v>` | Toggle horizontal / vertical terminal |
| `<leader>h` / `<leader>v` | **New** horizontal / vertical terminal |
| `<C-x>` | Leave terminal mode (back to normal) |
| `<leader>pt` | Pick a hidden terminal |

All [NvChad]. `<A-…>` toggles work from inside the terminal too.

---

## Completion — nvim-cmp, insert mode

| Key | Does | Source |
|---|---|---|
| `<C-y>` | **Accept** the highlighted item | [me] |
| `<CR>` | Accept (both work) | [NvChad] |
| `<C-n>` / `<C-p>` | Next / previous item | [NvChad] |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump snippet placeholders | [NvChad] |
| `<C-Space>` | Open the menu | [NvChad] |
| `<C-e>` | Close the menu | [NvChad] |
| `<C-d>` / `<C-f>` | Scroll the docs popup down / up | [NvChad] |

**Accepting also inserts the `#include`.** Type `std::vec` in a file with no
`<vector>`, press `<C-y>`, and `#include <vector>` appears at the top — clangd
attaches the edit to the completion item and cmp applies it on confirm. The `•`
prefix on an item marks completions that will add a header.

`<C-y>` was added because NvChad binds none, so it fell through to Vim's
built-in "copy the character above" — which is what made completion look broken.

**Insert-mode movement** [NvChad]: `<C-b>` start of line, `<C-e>` end of line,
`<C-h/j/k/l>` left/down/up/right.

---

## Editing, comments, selection

| Key | Does | Source |
|---|---|---|
| `<leader>/` | Toggle comment — normal and visual | [NvChad] |
| `gcc` | Toggle comment line | [nvim] |
| `gc` | Comment operator — `gc3j`, `gcap`, or a visual selection | [nvim] |
| `gx` | Open the URL or filepath under the cursor | [nvim] |
| `<leader>fm` | Format the buffer now — normal and visual | [NvChad] |
| `<leader>n` / `<leader>rn` | Toggle line numbers / relative numbers | [NvChad] |

**Treesitter node selection** [nvim], visual and operator-pending:

| Key | Does |
|---|---|
| `an` | Select the parent (outer) node |
| `in` | Select the child (inner) node |
| `]n` / `[n` | Next / previous node |
| `]N` / `[N` | Next / previous sibling node |

---

## Formatting

Runs on save; `<leader>fm` to force it. Timeout is 2000ms because black and
gersemi pay Python startup on their first run in a session.

| Filetype | Formatter | Style from |
|---|---|---|
| c, cpp | clang-format | `~/.clang-format` — LLVM base, IndentWidth 4 |
| cmake | gersemi | defaults |
| python | black | defaults |
| lua | stylua | `.stylua.toml` in this repo |

C/C++ buffers are forced to `shiftwidth=4` to match clang-format — otherwise
every newly typed line gets rewritten on save. Lua stays at 2.

---

## Discovery

| Key | Does |
|---|---|
| `<leader>ch` | **NvCheatsheet** — every mapping with a `desc`, live |
| `<leader>wK` | which-key: all keymaps |
| `<leader>wk` | which-key: query a specific prefix |
| `<leader>fh` | Telescope help pages |
| `g?` | nvim-tree's own keymap list (inside the tree) |
| `?` | lazygit's context menu (inside lazygit) |

`<leader>ch` is the live version of this file. If something here is stale,
`<leader>ch` is right and this is wrong.

---

## Conflicts and gotchas

- **`<leader>b` is the debugger breakpoint**, not NvChad's "new buffer". Use
  `:enew` for a new buffer.
- **`s` in the file tree** is vsplit, not "Run System". Outside the tree, `s` is
  still Vim's substitute.
- **`<C-x>`** is escape-terminal-mode in a terminal, and cut-file in the tree.
  Different modes, no actual clash.
- **`<C-s>`** saves in normal mode and requests signature help in insert/visual
  — and signature help is disabled for clangd deliberately.
- **`<C-h/j/k/l>`** are window/pane movement in normal mode but cursor movement
  in insert mode.
- **Keymap ordering**: `mappings.lua` runs last, in a `vim.schedule`, so it wins
  over NvChad. A plugin that maps at load time will beat it — that is why the
  tmux navigator keys are set in `mappings.lua` with the plugin's own maps
  disabled.

---

## Not bound

Worth knowing about, currently absent:

- **Every gitsigns action.** No stage-hunk, reset-hunk, preview-hunk, blame-line,
  or hunk navigation. The plugin is loaded and drawing signs, but no `on_attach`
  gives it keys. The conventional set would be `<leader>hs` stage, `<leader>hr`
  reset, `<leader>hp` preview, `<leader>hb` blame, `]h` / `[h` navigate.
- **`<leader>fs`-style document symbols** — `gO` covers it.
- **Session management** — no persistence plugin.
- **Harpoon / mark-jumping** — `<leader>ma` lists Vim marks, nothing more.
