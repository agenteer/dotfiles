-- The color scheme. This is taste, not practice - pick any theme with good
-- contrast; contrast on a diff is the only thing that matters here.
return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup({ commentStyle = { italic = false }, keywordStyle = { italic = false } })
      vim.cmd('colorscheme kanagawa')
    end,
  },
}
