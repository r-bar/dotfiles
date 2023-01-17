local M = {}

function M.packages(use)
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'saadparwaiz1/cmp_luasnip'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lua'

  -- Snippets
  use 'L3MON4D3/LuaSnip'
  use 'rafamadriz/friendly-snippets'
  use 'honza/vim-snippets'
  use 'https://github.com/molleweide/LuaSnip-snippets.nvim.git'

  use 'VonHeikemen/lsp-zero.nvim'
end

function M.config()
  local lsp = require('lsp-zero')
  local luasnip = require('luasnip')

  --lsp.preset('system-lsp')
  lsp.preset('recommended')

  luasnip.config.setup{
    -- When false you cannot jump back into a snippet once it is complete.
    -- Turning it off lets the snippet function exit after you are done.
    -- This prevents the plugin or keybinds from conflicting.
    history = false;
  }
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()

  lsp.configure("rust_analyzer", {
    settings = {
      ["rust-analyzer"] = {
        cargo = { loadOutDirsFromCheck = true };
        procMacro = { enable = true };
        updates = { channel = "nightly" };
        checkOnSave = { command = "clippy" };
        diagnostics = { experimental = { enable = true } };
      };
    };
  })
  lsp.configure("pylsp", {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    --on_attach = function(client, bufnr)
    --  -- https://neovim.discourse.group/t/preserve-internal-formatting-when-using-gq-motion/3159/2
    --  vim.opt.formatexpr = ""
    --end,
    settings = {
      pylsp = {
        configurationSources = {
          'flake8',
          --'pycodestyle',
          'pydocstyle',
          'rope',
          'mccabe',
          'black',
          'flake8',
          'pylint',
          'isort',
          'pylsp_rope',
        },
        plugins = {
          pylsp_mypy = { enabled = false },
          pycodestyle = { enabled = false },
        },
      },
    },
  })
  --lsp.setup_servers{
  --  "ansiblels",
  --  "bashls",
  --  "cssls",
  --  "dockerls",
  --  "jsonnet_ls",
  --  "pylsp",
  --  "rust_analyzer",
  --  "sqlls",
  --  "sumneko_lua",
  --  "svelte",
  --  "tsserver",
  --  "vls",
  --  "yamlls",
  --}
  lsp.setup()

  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
  vim.cmd [[command Format :lua vim.lsp.buf.format{async = false}]]
  vim.cmd [[command LspDiagnostics :lua vim.diagnostic.setqflist()]]
    vim.cmd [[
    function! LspRestart()
      lua vim.lsp.buf.clear_references()
      lua vim.lsp.stop_client(vim.lsp.get_active_clients())
      edit
    endfunc
    command LspRestart :call LspRestart()
  ]]
  vim.api.nvim_create_autocmd({"VimLeavePre"}, {
    callback = function()
      vim.fn.system("rm $HOME/.local/state/nvim/lsp.log")
    end,
  })
end

return M
