## Core

- `Alt+w` — save file
- `Alt+q` — quit
- `Z` — LazyGit (floating window); `ZZ` / `ZQ` are disabled
- `Ctrl+y` — yazi picker (overrides Vim-default scroll-up)
- files auto-format on save (conform); no manual format key

## Motion

- `g h` — first character of line
- `g l` — last character of line

## CSV (auto-rendered table)

- opens as an aligned table with sticky header; `:CsvViewToggle` to switch back to raw text

## Space menu (leader = space)

- `Space f` — file picker, text files only (input focused, type right away)
- `Space F` — files in current buffer's directory
- `Space b` — buffers (input focused, type right away)
- `Space g` — git status
- `Space /` — live grep
- `Space d` — diagnostics
- snacks pickers never dim the current buffer
- `Space x` — diagnostics list (Trouble)
- `Space y` — yank selection to system clipboard (visual)
- `Space p` — paste from system clipboard
- `Space q` — calculator (qalc)
- `Space a` — outline (Aerial)
- `Space Space` — reload buffer
- `Space c` — code action
- `Space r` — rename symbol
- `Space D` — go to definition
- `Space h` — hover docs
- `Space i` — toggle inlay hints

## Git review (Space G)

- `Space G s` — stage hunk
- `Space G r` — reset hunk
- `Space G p` — preview hunk
- `Space G b` — blame line
- `Space G d` — diff current buffer
- `Space G D` — side-by-side diff (Diffview, `q` to quit)
- `Space G l` — file history (Diffview, `q` to quit)
- `]c` / `[c` — next / prev hunk (same: `]g` / `[g`)
- `]G` / `[G` — last / first change in file

## AI completion (minuet, DeepSeek V4.1 Flash)

- `Alt+y` (insert mode) — invoke manually (auto is off: no network lag while typing)
- `Ctrl+n` / `Ctrl+p` — next / prev suggestion; `Ctrl+y` or `Enter` — accept; `Ctrl+e` — dismiss

## Surround / comment

- `m s` — add surround
- `m d` — delete surround
- `m r` — replace surround
- `g c` — toggle comment
- brackets and quotes auto-close; enhanced `i` / `a` textobjects

## Outline (Aerial)

- `{` / `}` — prev / next symbol

## Debug (DAP)

- `F5` — continue / start
- `F10` — step over
- `F11` — step into
- `F12` — step out
- `Space B b` — toggle breakpoint
- `Space B c` — conditional breakpoint
- `Space B r` — REPL
- `Space B u` — debug UI
- `Space B t` — terminate session
