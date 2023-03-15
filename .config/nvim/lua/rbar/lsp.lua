local M = {}
M.lsp_flags = {}

function M.packages(use)
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use {'williamboman/mason-lspconfig.nvim', config = M.mason_config}

  -- Autocompletion
  use {'hrsh7th/nvim-cmp', config = M.nvim_cmp_config}
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

  --use 'VonHeikemen/lsp-zero.nvim'
end

function M.mason_config()
  -- order is important. these mason setup calls must be done before lspconfig
  -- servers are configured
  require('mason').setup{
    ensure_installed = {
      "ansiblels",
      "bashls",
      "cssls",
      "docker_compose_language_service",
      "dockerls",
      "html",
      "jq",
      "jsonls",
      "jsonnet_ls",
      "lua_ls",
      "marksman",
      "nil_ls", -- nix
      "ocamllsp",
      "ocamlformat",
      "rnix", -- nix
      "ruff_lsp", -- python
      "rust_analyzer",
      "rustfmt",
      "sqlls",
      "tailwindcss",
      "vimls",
      "yamlls",
    },
    automatic_installation = false,
  }
  require('mason-lspconfig').setup()
end

local function has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return col ~= 0 and line_text:sub(col, col):match("%s") == nil
end

local function is_whitespace()
    -- returns true if the character under the cursor is whitespace.
    local col = vim.fn.col('.') - 1
    local line = vim.fn.getline('.')
    local char_under_cursor = string.sub(line, col, col)

    return col == 0 or string.match(char_under_cursor, '%s')
end

function M.nvim_cmp_config()
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  vim.o.completeopt = 'menuone,noinsert,noselect,preview'

  local mappings = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-c>'] = cmp.mapping.abort(),
    -- Accept currently selected item. Set `select` to `false` to only confirm
    -- explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = false }),

    --["<Tab>"] = cmp.mapping.select_next_item{ behavior = cmp.SelectBehavior.Select },
    --["<S-Tab>"] = cmp.mapping.select_prev_item{ behavior = cmp.SelectBehavior.Select },

    -- manual supertab like completion from the nvim-cmp wiki
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        --cmp.select_next_item{ behavior = cmp.SelectBehavior.Select }
        cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
        -- they way you will only jump inside the snippet region
      --elseif luasnip.expand_or_jumpable() then
      --  luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        --cmp.select_prev_item{ behavior = cmp.SelectBehavior.Select }
        cmp.select_prev_item()
      --elseif luasnip.jumpable(-1) then
      --  luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }

  cmp.setup({
    --enabled = function() return not is_whitespace() end,
    --completion = {
    --  keyword_length = 2,
    --},
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
         luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert(mappings),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    }),
  })

  ---- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(mappings),
    sources = {
      { name = 'buffer' },
    },
  })

  ---- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  --cmp.setup.cmdline(':', {
  --  mapping = cmp.mapping.preset.cmdline(mappings),
  --  sources = cmp.config.sources({
  --    { name = 'path' },
  --    { name = 'cmdline' },
  --  }),
  --})

  -- Set up lspconfig.
end

function M.luasnip_config()
  local luasnip = require('luasnip')
  luasnip.config.setup{
    -- When false you cannot jump back into a snippet once it is complete.
    -- Turning it off lets the snippet function exit after you are done.
    -- This prevents the plugin or keybinds from conflicting.
    history = false;
  }
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()

end

function M.on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  --vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

function M.global_bindings()
  vim.cmd [[command Format :lua vim.lsp.buf.format{async = false}]]
  vim.cmd [[command LspDiagnostics :lua vim.diagnostic.setqflist()]]
  vim.api.nvim_create_user_command(
    "LspRestart",
    function()
      vim.lsp.buf.clear_references()
      vim.lsp.stop_client(vim.lsp.get_active_clients())
      vim.cmd[[edit]]
    end,
    {}
  )
  --vim.cmd [[
  --  function! LspRestart()
  --    lua vim.lsp.buf.clear_references()
  --    lua vim.lsp.stop_client(vim.lsp.get_active_clients())
  --    edit
  --  endfunc
  --  command LspRestart :call LspRestart()
  --]]
  local opts = { noremap=true, silent=true }
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

function M.capabilities()
  return require('cmp_nvim_lsp').default_capabilities()
end

function M.default_server_settings()
  return {
    capabilities = M.capabilities(),
    on_attach = M.on_attach,
    flags = M.lsp_flags,
  }
end

function M.server_settings()
  local lsputil = require('lspconfig.util')

  local settings = {}
  -- the below servers tend to need to be installed globally to work correctly

  settings['lua_ls'] = vim.tbl_extend("force", M.default_server_settings(), {
    settings = {
      Lua = {
        diagnostics = {
          globals = {'vim'},
        },
      },
    },
  })

  settings['pylsp'] = vim.tbl_extend("force", M.default_server_settings(), {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    --on_attach = function(client, bufnr)
    --  -- https://neovim.discourse.group/t/preserve-internal-formatting-when-using-gq-motion/3159/2
    --  vim.opt.formatexpr = ""
    --end,
    force_setup = true,
    settings = {
      pylsp = {
        configurationSources = {
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
          pyflakes = { enabled = false },
          black = { enabled = true },
          rope = { enabled = true },
          flake8 = { enabled = true },
        },
      },
    },
  })

  settings['rust_analyzer'] = vim.tbl_extend("force", M.default_server_settings(), {
    settings = {
      ["rust-analyzer"] = {
        cargo = { loadOutDirsFromCheck = true },
        procMacro = { enable = true },
        updates = { channel = "nightly" },
        checkOnSave = { command = "clippy" },
        diagnostics = { experimental = { enable = true } },
      },
    },
  })

  -- https://github.com/vlang/vls
  settings['vls'] = vim.tbl_extend("force", M.default_server_settings(), {
    cmd = {'v', 'ls'},
    filetypes = {'vlang'},
    root_dir = lsputil.find_git_ancestor,
    docs = {
      description = [[
https://github.com/vlang/vls

The V language server can be installed via `v ls --install`.

The official V language server, written in V itself.
]]
    },
  })

  return settings
end

function M.config()
  local lspconfig = require('lspconfig')

  -- lsp debug logging
  -- clear the lsp log before every session
  vim.fn.system("rm $HOME/.local/state/nvim/lsp.log")
  vim.lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or "debug")

  M.global_bindings()

  require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function (server_name) -- default handler (optional)
      require("lspconfig")[server_name].setup(M.default_server_settings())
    end,
  }
  for name, settings in pairs(M.server_settings()) do
    lspconfig[name].setup(settings)
  end
end

return M
