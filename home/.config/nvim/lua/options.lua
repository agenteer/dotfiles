local o = vim.opt

-- Space is the key you press before every shortcut below.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Show the line number on every line. Diffs and error messages cite line
-- numbers, and absolute numbers are how you find the one they mean.
o.number = true
-- Relative numbering is left off on purpose: it speeds up jump-and-edit
-- motions for someone typing code, not "go to line 214" for someone reading it.

-- Copying inside the editor puts the text on the system clipboard, so it can
-- be pasted anywhere outside the editor too.
o.clipboard = 'unnamedplus'

-- Keep undo history after closing a file, so you can undo a change from an
-- earlier session even after the file has been edited again since.
o.undofile = true

-- Searching ignores capitals unless you type one yourself.
o.ignorecase = true
o.smartcase = true

-- Keep 10 lines of context above and below the cursor instead of letting it
-- hit the edge of the window.
o.scrolloff = 10

-- Leave the mouse on: scrolling and clicking should not require knowing vim.
o.mouse = 'a'

-- Reserve a narrow column on the left for git/diagnostic markers, so the text
-- doesn't shift sideways when a marker appears or disappears.
o.signcolumn = 'yes'

-- Faintly highlight the line the cursor is on, to keep your place in a wall
-- of changed lines.
o.cursorline = true

-- New split windows open to the right and below, so a side-by-side view
-- reads left-to-right as old-then-new.
o.splitright = true
o.splitbelow = true

-- Draw tabs, trailing spaces, and non-breaking spaces as visible marks.
-- Trailing whitespace is otherwise invisible and shows up as an unexplained
-- diff line.
o.list = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Ask "save first?" instead of refusing to quit with unsaved changes.
o.confirm = true

-- React faster, including how quickly the keybinding-hint popup appears.
o.updatetime = 250
o.timeoutlen = 300

-- Indent width is not set here: a plugin (guess-indent, in lua/plugins/editor.lua) detects it per
-- file, since a reader opens files in whatever style their project already uses.
