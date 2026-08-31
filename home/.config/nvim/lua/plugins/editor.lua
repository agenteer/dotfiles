return {
  -- Type part of a filename or a phrase and jump straight to it.
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = { picker = { enabled = true }, notifier = { enabled = true }, input = { enabled = true } },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end,   desc = 'Find files' },
      { '<leader>s', function() Snacks.picker.grep() end,    desc = 'Search text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Open files' },
    },
  },

  -- Press the leader key and a menu pops up showing what you can press next,
  -- so nothing here has to be memorized.
  { 'folke/which-key.nvim', lazy = false, config = true },

  -- Colors code by understanding its structure rather than guessing at
  -- words. Includes parsers for diffs and markdown, which is most of what
  -- an agent's output looks like.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- the stable configuration API; the default branch is a newer rewrite with a different setup
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'diff', 'lua', 'luadoc', 'markdown',
        'markdown_inline', 'vim', 'vimdoc', 'json', 'yaml', 'nix' },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Looks at the file you just opened and matches its indentation, instead
  -- of forcing every file to a fixed width.
  { 'NMAC427/guess-indent.nvim', event = 'BufReadPre', opts = {} },
}
