-- LSP server integration

---@class M ConfigPkg
local M = {}
local lsp_flags = {}

-- order is important. these mason setup calls must be done before lspconfig
-- servers are configured
local function mason_ensure_installed()
  local ensure_installed = {
    "bashls",
    "docker_compose_language_service",
    "cssls",
    "dockerls",
    "html",
    "jsonls",
    "jsonnet_ls",
    "lua_ls",
    "marksman",
    "pylsp",
    "sqlls",
    "ts_ls",
    "tailwindcss",
    "vimls",
    "yamlls",
  }

  if vim.fn.executable("nix") == 1 then
    table.insert(ensure_installed, "nil_ls")
    table.insert(ensure_installed, "rnix")
  end

  if vim.fn.executable("ansible") == 1
      and vim.fn.executable("ansible-lint") == 1
      and vim.fn.executable("ansible-config") == 1
  then
    table.insert(ensure_installed, "ansiblels")
  end

  return ensure_installed
end

local function on_attach(client, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local function bufopts(kwargs)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    if kwargs then
      vim.tbl_extend("force", opts, kwargs)
    end
    return opts
  end
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts { desc = "Go to declaration" })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts { desc = "Go to definition" })
  --vim.keymap.set('n', 'gv', ":vsplit<cr>gd", bufopts { desc = "Go to definition in new vsplit" })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts { desc = "Show hover info" })
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts { desc = "Go to implementation" })
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts { desc = "Show signature help" })
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts { desc = "Show signature help" })
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts { desc = 'Add workspace folder' })
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts { desc = 'Remove workspace folder' })
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts { desc = 'List workspace folders' })
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts { desc = "Show type definition" })
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts { desc = "Rename" })
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts { desc = "Rename" })
  vim.keymap.set('n', '<leader>a', require('fzf-lua').lsp_code_actions, bufopts { desc = "Perform code action" })
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts { desc = "Find references" })
  vim.keymap.set('n', '<leader>ff', function() vim.lsp.buf.format { async = true } end, bufopts { desc = "Format file" })

  -- disable semantic token highlighting
  client.server_capabilities.semanticTokensProvider = nil
end

function M.global_bindings()
  local default_opts = { noremap = true, silent = true }
  local function opts(extra)
    return vim.tbl_extend("force", default_opts, extra or {})
  end
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts { desc = 'Show diagnostic error in floating window' })
  vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end,
    opts { desc = 'Jump to prev diagnostic error' })
  vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end,
    opts { desc = 'Jump to next diagnostic error' })
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts { desc = 'Show buffer diagnostic errors' })
end

local function default_server_settings()
  return {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = on_attach,
    flags = lsp_flags,
  }
end

local function with_defaults(custom)
  if custom == nil then
    return default_server_settings()
  end
  return vim.tbl_extend("force", default_server_settings(), custom)
end

local function find_git_ancestor(startpath)
  return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
end

local function server_settings()
  local settings = {}

  settings['gleam'] = with_defaults()

  settings['lua_ls'] = with_defaults({
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' },
        },
      },
    },
  })

  if false and vim.fn.executable('opam') == 1 then
    settings['ocamllsp'] = with_defaults()
  end

  settings['pylsp'] = with_defaults({
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    --on_attach = function(client, bufnr)
    --  -- https://neovim.discourse.group/t/preserve-internal-formatting-when-using-gq-motion/3159/2
    --  vim.opt.formatexpr = ""
    --end,
    force_setup = true,
    settings = {
      pylsp = {
        configurationSources = {
          'pycodestyle',
          'pydocstyle',
          'rope',
          'mccabe',
          --'black',
          'flake8',
          'pylint',
          'isort',
          'pylsp_rope',
        },
        plugins = {
          black = { enabled = false },
          rope = { enabled = true },
          pylsp_mypy = { enabled = true },
          -- lints generally covered by black and ruff while being less configurable
          pyflakes = { enabled = false },
          flake8 = { enabled = false },
          pycodestyle = { enabled = false },
          -- moved to its own lsp server
          --ruff = {
          --  enabled = true,       -- Enable the plugin
          --  formatEnabled = true, -- Enable formatting using ruffs formatter
          --  format = { "I" },     -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
          --  unsafeFixes = false,  -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action

          --  -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
          --  lineLength = 88,                                 -- Line length to pass to ruff checking and formatting
          --  perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
          --  preview = false,                                 -- Whether to enable the preview style linting and formatting.
          --  targetVersion = "py310",                         -- The minimum python version to target (applies for both lint and format)
          --}
        },
      },
    },
  })

  if vim.fn.executable("pylsp") == 1 then
    settings.pylsp.cmd = { "pylsp" }
  end

  if vim.fn.executable("ruff") then
    settings["ruff"] = with_defaults()
  end

  settings['roc_ls'] = with_defaults()

  settings['rust_analyzer'] = with_defaults({
    settings = {
      ["rust-analyzer"] = {
        cargo = { loadOutDirsFromCheck = true },
        procMacro = { enable = true },
        updates = { channel = "nightly" },
        checkOnSave = true,
        diagnostics = { experimental = { enable = true } },
      },
    },
  })

  -- https://github.com/vlang/vls
  settings['vls'] = with_defaults({
    cmd = { 'v', 'ls' },
    filetypes = { 'vlang' },
    root_dir = find_git_ancestor,
    docs = {
      description = [[
https://github.com/vlang/vls

The V language server can be installed via `v ls --install`.

The official V language server, written in V itself.
]]
    },
  })

  settings['mojo'] = with_defaults()

  settings['zls'] = with_defaults({
    cmd = { 'zls' },
    filetypes = { 'zig' },
    root_dir = find_git_ancestor,
    docs = {
      description = [[
[ZLS](https://github.com/zigtools/zls)

[Configuration Options](https://github.com/zigtools/zls#configuration-options)
]]
    },
    -- https://github.com/zigtools/zls#configuration-options
    settings = {
      zls = {
        enable_autofix = false,
      },
    },
  })

  return settings
end

function M.packages(use)
  use 'neovim/nvim-lspconfig'
  use { 'williamboman/mason.nvim', version = '^2.0.0', opts = { PATH = "append" } }
  use {
    'williamboman/mason-lspconfig.nvim',
    version = '^2.0.0',
    opts = { ensure_installed = mason_ensure_installed() }
  }
  -- gives a nice live lsp status message in the bottom right corner
  use { 'j-hui/fidget.nvim', opts = {} }

  use {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  }
end

function M.config()
  -- lsp debug logging
  -- clear the lsp log before every session
  vim.fn.system("rm $HOME/.local/state/nvim/lsp.log")
  vim.lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or "warn")

  vim.api.nvim_create_user_command("Format", function() vim.lsp.buf.format { async = false } end, {})
  vim.api.nvim_create_user_command("LspDiagnostics", function() vim.diagnostic.setqflist() end, {})
  --vim.api.nvim_create_user_command(
  --  "LspRestart",
  --  function()
  --    vim.lsp.buf.clear_references()
  --    vim.lsp.stop_client(vim.lsp.get_clients())
  --    vim.cmd [[edit]]
  --  end,
  --  {}
  --)

  M.global_bindings()

  for name, settings in pairs(server_settings()) do
    vim.lsp.config(name, settings)
    vim.lsp.enable(name)
  end
end

return M
