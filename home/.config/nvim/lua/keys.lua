local map = vim.keymap.set

-- Escape clears the leftover yellow search highlight, instead of doing
-- anything more surprising with the "get me out of here" key.
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save every open buffer automatically when you switch away from the editor
-- or the window loses focus, so you never lose an edit by forgetting to save.
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost' }, { command = 'silent! wall' })

-- Pasting over a selected block keeps whatever was on your clipboard,
-- instead of replacing it with the text you just overwrote.
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- Move between split windows with Control plus a direction.
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Window left' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Window down' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Window up' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Window right' })
