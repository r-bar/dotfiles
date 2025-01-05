---@type ConfigPkg
local M = {}
local lsp_flags = {}

-- order is important. these mason setup calls must be done before lspconfig
-- servers are configured
local function mason_config()
  local ensure_installed = {
    "ansiblels",
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

  require('mason').setup { PATH = "append" }
  require('mason-lspconfig').setup({
    automatic_installation = true,
    ensure_installed = ensure_installed,
  })
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
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts{ desc = "Go to declaration" })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts{})
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts{})
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts{})
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts{})
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts{})
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts{})
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts{})
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts{})
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts{})
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts{})
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts{})
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts{})
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts{})
  vim.keymap.set('n', '<leader>ff', function() vim.lsp.buf.format { async = true } end, bufopts{})

  -- disable semantic token highlighting
  client.server_capabilities.semanticTokensProvider = nil
end

function M.global_bindings()
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

local function capabilities()
  -- originally from require('cmp_nvim_lsp').default_capabilities()
  return {
    textDocument = {
      completion = {
        completionItem = {
          commitCharactersSupport = true,
          deprecatedSupport = true,
          insertReplaceSupport = true,
          insertTextModeSupport = {
            valueSet = { 1, 2 }
          },
          labelDetailsSupport = true,
          preselectSupport = true,
          resolveSupport = {
            properties = { "documentation", "additionalTextEdits", "insertTextFormat", "insertTextMode", "command" }
          },
          snippetSupport = true,
          tagSupport = {
            valueSet = { 1 }
          }
        },
        completionList = {
          itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" }
        },
        contextSupport = true,
        dynamicRegistration = false,
        insertTextMode = 1
      }
    }
  }
end

local function default_server_settings()
  return {
    capabilities = capabilities(),
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

local function server_settings()
  local lsputil = require('lspconfig.util')

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

  settings['ocamllsp'] = with_defaults()

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
          pylsp_mypy = { enabled = false },
          -- lints generally covered by black and ruff while being less configurable
          pyflakes = { enabled = false },
          flake8 = { enabled = false },
          pycodestyle = { enabled = false },
          ruff = {
            enabled = true,       -- Enable the plugin
            formatEnabled = true, -- Enable formatting using ruffs formatter
            format = { "I" },     -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
            unsafeFixes = false,  -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action

            -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
            lineLength = 88,                                 -- Line length to pass to ruff checking and formatting
            perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
            preview = false,                                 -- Whether to enable the preview style linting and formatting.
            targetVersion = "py310",                         -- The minimum python version to target (applies for both lint and format)
          }
        },
      },
    },
  })

  if vim.fn.executable("pylsp") == 1 then
    settings.pylsp.cmd = { "pylsp" }
  end

  settings['roc_ls'] = with_defaults()

  settings['rust_analyzer'] = with_defaults({
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
  settings['vls'] = with_defaults({
    cmd = { 'v', 'ls' },
    filetypes = { 'vlang' },
    root_dir = lsputil.find_git_ancestor,
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
    root_dir = lsputil.find_git_ancestor,
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
  use 'williamboman/mason.nvim'
  use { 'williamboman/mason-lspconfig.nvim', config = mason_config }
  -- gives a nice live lsp status message in the bottom right corner
  use { 'j-hui/fidget.nvim', opts = {} }

  -- Autocompletion
  use { -- optional blink completion source for require statements and module annotations
    "saghen/blink.cmp",
    --version = "v0.*",
    version = "*",
    --init = function()
    --  vim.fn.stdpath('data') .. "/lazy/blink.cmp"
    --  vim.fn.system("cargo build --release")
    --end,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.
      keymap = {
        preset = nil,
        ['<C-e>'] = { 'hide' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<Tab>'] = {
          --function(cmp)
          --  if cmp.snippet_active() then return cmp.accept()
          --  else return cmp.select_and_accept() end
          --end,
          'select_next',
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = {
          'select_prev',
          'snippet_backward',
          'fallback',
        },
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        list = { selection = 'auto_insert' },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        --use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
        kind_icons = {
          Copilot = "",
        },
      },

      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        default = {
          "copilot",
          "lsp",
          "path",
          "snippets",
          "buffer",
          "lazydev",
          "dadbod",
        },
        -- optionally disable cmdline completions
        -- cmdline = {},
        providers = {
          -- dont show LuaLS require statements when lazydev has items
          lsp = { fallbacks = { "lazydev" } },
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
          copilot = {
            name = "Copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
        },
      },

      -- experimental signature help support
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
    dependencies = {
      "folke/lazydev.nvim",
      "giuxtaposition/blink-cmp-copilot",
      "zbirenbaum/copilot.lua",
    }
  }

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

  -- Snippets
  use {
    'L3MON4D3/LuaSnip',
    version = "v2.*",
    opts = {
      -- When false you cannot jump back into a snippet once it is complete.
      -- Turning it off lets the snippet function exit after you are done.
      -- This prevents the plugin or keybinds from conflicting.
      history = false,
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'honza/vim-snippets',
      'https://github.com/molleweide/LuaSnip-snippets.nvim.git',
    },
  }

  use {
    "zbirenbaum/copilot.lua",
    enabled = vim.env.DISABLE_COPILOT == nil,
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        trigger_characters = { ".", ":", " ", "\t" },
      },
      panel = { enabled = true },
    }
  }
end

function M.config()
  local lspconfig = require('lspconfig')

  -- lsp debug logging
  -- clear the lsp log before every session
  vim.fn.system("rm $HOME/.local/state/nvim/lsp.log")
  vim.lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or "debug")

  vim.api.nvim_create_user_command("Format", function() vim.lsp.buf.format { async = false } end, {})
  vim.api.nvim_create_user_command("LspDiagnostics", function() vim.diagnostic.setqflist() end, {})
  vim.api.nvim_create_user_command(
    "LspRestart",
    function()
      vim.lsp.buf.clear_references()
      vim.lsp.stop_client(vim.lsp.get_active_clients())
      vim.cmd [[edit]]
    end,
    {}
  )

  M.global_bindings()

  require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
      lspconfig[server_name].setup(default_server_settings())
    end,
  }
  for name, settings in pairs(server_settings()) do
    lspconfig[name].setup(settings)
  end
end

return M