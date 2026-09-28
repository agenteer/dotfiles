local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
local lock = vim.json.decode(table.concat(vim.fn.readfile(lockfile), "\n"))
local plugins = vim.fn.stdpath("data") .. "/lazy/"
local function bootstrap(name, repository)
  local path = plugins .. name
  if not vim.uv.fs_stat(path) then
    local commit = assert(lock[name] and lock[name].commit, "Missing locked plugin: " .. name)
    -- An interrupted checkout must not look like a completed installation next time.
    local staging = path .. ".bootstrap-" .. vim.uv.os_getpid() .. "-" .. tostring(vim.uv.hrtime())
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--no-checkout",
      "https://github.com/" .. repository .. ".git", staging })
    if vim.v.shell_error ~= 0 then
      vim.fn.delete(staging, "rf")
      error(name .. " bootstrap failed: " .. out)
    end
    out = vim.fn.system({ "git", "-C", staging, "checkout", "--detach", commit })
    if vim.v.shell_error ~= 0 then
      vim.fn.delete(staging, "rf")
      error(name .. " locked checkout failed: " .. out)
    end
    local ok, err = vim.uv.fs_rename(staging, path)
    if not ok then
      vim.fn.delete(staging, "rf")
      error(name .. " installation failed: " .. tostring(err))
    end
  end
  return path
end
local lazypath = bootstrap("lazy.nvim", "folke/lazy.nvim")
-- Load the complete distribution spec before the first install resolves its plugins.
-- Incremental discovery can otherwise rewrite pins for plugins found in a later pass.
bootstrap("LazyVim", "LazyVim/LazyVim")
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", version = "16.0.1", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  checker = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "kanagawa", "habamax" } },
  performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "zipPlugin" } } },
})
