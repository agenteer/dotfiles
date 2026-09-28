local nix = dofile(vim.env.WORKSTATION_NVIM_NIX_PATHS or vim.fn.expand("~/.config/nvim-nix.lua"))
return {
  -- Nix owns external executables and compiled parsers, never Mason/download hooks.
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  {
    "nvim-treesitter/nvim-treesitter",
    dir = nix.treesitter,
    build = false,
    opts = function(_, opts)
      opts.ensure_installed = {}
      opts.install_dir = nix.parsers
      -- Complete upstream queries include shared ecma, jsx and html_tags rules.
      -- The grammar-only install directory omits these non-parser parents.
      vim.opt.rtp:append(nix.treesitter .. "/runtime")
      -- Native language indenters handle partially typed code consistently.
      opts.indent = { enable = false }
      -- Native XML indentation needs legacy syntax groups; use its matching highlighter.
      opts.highlight = opts.highlight or {}
      opts.highlight.disable = { "xml" }
    end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects", dir = nix.textobjects, build = false },
  {
    "saghen/blink.cmp",
    build = false,
    opts = { fuzzy = { implementation = "lua", prebuilt_binaries = { download = false } } },
  },
  { "rebelot/kanagawa.nvim" },
  { "LazyVim/LazyVim", opts = { colorscheme = "kanagawa" } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        vtsls = { mason = false, settings = {
          typescript = { disableAutomaticTypeAcquisition = true },
        } },
        pyright = { mason = false },
        ruff = { mason = false },
        lua_ls = { mason = false },
        nil_ls = { mason = false },
        bashls = { mason = false },
        jsonls = { mason = false },
        yamlls = { mason = false },
        taplo = { mason = false },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" }, javascriptreact = { "prettier" },
        typescript = { "prettier" }, typescriptreact = { "prettier" },
        json = { "prettier" }, jsonc = { "prettier" }, yaml = { "prettier" },
        markdown = { "prettier" }, python = { "ruff_format" },
        lua = { "stylua" }, sh = { "shfmt" }, bash = { "shfmt" }, nix = { "nixfmt" },
      },
    },
  },
  -- Keep the recording surface focused; integrations remain available on demand.
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      scroll = { enabled = false },
      terminal = { win = { position = "right" } },
      -- Lazygit also uses Snacks.terminal; retain its floating Git interface.
      lazygit = { win = { position = "float" } },
    },
  },
}
