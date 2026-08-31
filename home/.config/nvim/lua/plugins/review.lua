return {
  -- Puts a mark in the left margin on every line that was added, changed, or
  -- deleted, and shows who last touched the line under the cursor. This is
  -- the tool that answers "what changed here" without leaving the file.
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = '+' }, change = { text = '~' }, delete = { text = '_' },
        topdelete = { text = '‾' }, changedelete = { text = '~_' },
      },
    },
  },

  -- Opens the old and new versions of a file (or a whole change set)
  -- side by side. This is the actual tool for reviewing what an agent wrote.
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>d', '<cmd>DiffviewOpen<cr>', desc = 'Review changes side by side' },
      { '<leader>D', '<cmd>DiffviewFileHistory %<cr>', desc = 'History of this file' },
    },
  },
}
