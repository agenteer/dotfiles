-- Save/format are explicit actions: no invisible edits during agent handoffs.
vim.opt.autowrite = false
vim.opt.autowriteall = false
vim.g.autoformat = false
vim.g.snacks_animate = false
vim.opt.relativenumber = false
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.conceallevel = 0 -- Show the actual Markdown being taught.
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
