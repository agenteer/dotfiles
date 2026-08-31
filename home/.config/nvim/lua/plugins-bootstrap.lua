-- Downloads the plugin manager itself on first run, then hands control to it.
-- Every file under lua/plugins/ is loaded automatically.
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none',
    -- why the exact version: with '--branch=stable' the first start records whatever is newest and rewrites
    -- lazy-lock.json on a fresh machine; pinned, the lock matches and nothing changes behind your back.
    'https://github.com/folke/lazy.nvim.git', '--branch=v11.17.5', lazypath })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup('plugins')
