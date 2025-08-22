---@class M ConfigPkg
local M = {}
local lsp_flags = {}
local OLLAMA_BASE_URL = "http://earth.ts.barth.tech:11434"

-- order is important. these mason setup calls must be done before lspconfig
-- servers are configured
local function mason_config()
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
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts { desc = "Go to declaration" })
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts {})
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts {})
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts {})
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts {})
  vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts {})
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts {})
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts {})
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts {})
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts {})
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts {})
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts {})
  vim.keymap.set('n', '<leader>a', require('fzf-lua').lsp_code_actions, bufopts {})
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts {})
  vim.keymap.set('n', '<leader>ff', function() vim.lsp.buf.format { async = true } end, bufopts {})

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
  return vim.lsp.protocol.make_client_capabilities()
  -- originally from require('cmp_nvim_lsp').default_capabilities()
  --return {
  --  textDocument = {
  --    completion = {
  --      completionItem = {
  --        commitCharactersSupport = true,
  --        deprecatedSupport = true,
  --        insertReplaceSupport = true,
  --        insertTextModeSupport = {
  --          valueSet = { 1, 2 }
  --        },
  --        labelDetailsSupport = true,
  --        preselectSupport = true,
  --        resolveSupport = {
  --          properties = { "documentation", "additionalTextEdits", "insertTextFormat", "insertTextMode", "command" }
  --        },
  --        snippetSupport = true,
  --        tagSupport = {
  --          valueSet = { 1 }
  --        }
  --      },
  --      completionList = {
  --        itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" }
  --      },
  --      contextSupport = true,
  --      dynamicRegistration = false,
  --      insertTextMode = 1
  --    }
  --  }
  --}
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

local _ollama_enabled_cache = nil

--- @param endpoint string?
local function ollama_enabled(endpoint)
  --return false
  if _ollama_enabled_cache ~= nil then
    return _ollama_enabled_cache
  end

  local hostname = vim.system({ "hostname", "-s" }, { text = true }):wait()
  if hostname.stdout == "ceres" then
    _ollama_enabled_cache = false
    return _ollama_enabled_cache
  end

  endpoint = endpoint or OLLAMA_BASE_URL
  local http_result = vim.system(
    { "curl", "-sfL", endpoint },
    { text = true, timeout = 0.1 }
  ):wait()
  if http_result == nil then
    _ollama_enabled_cache = false
    return _ollama_enabled_cache
  end
  _ollama_enabled_cache = http_result.stdout == "Ollama is running"
  return _ollama_enabled_cache
end
M.ollama_enabled = ollama_enabled

function M.blink_opts()
  local async_timeout_ms = 100
  local opts = {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- see the "default configuration" section below for full documentation on how to define
    -- your own keymap.
    keymap = {
      preset = nil,
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<C-y>'] = { 'select_and_accept', 'snippet_forward' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
      ['<Tab>'] = {
        --function(cmp)
        --  if cmp.snippet_active() then return cmp.accept()
        --  else return cmp.select_and_accept() end
        --end,
        'select_next',
        --'select_and_accept',
        --'insert_next',
        --'snippet_forward',
        'fallback',
      },
      ['<S-Tab>'] = {
        'select_prev',
        --'insert_prev',
        --'snippet_backward',
        'fallback',
      },
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },
      list = {
        selection = { preselect = false, auto_insert = true },
      },
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
        "snippets",
        "path",
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
        dadbod = {
          name = "Dadbod",
          module = "vim_dadbod_completion.blink",
          timeout_ms = async_timeout_ms,
        },
        copilot = {
          name = "Copilot",
          module = "blink-cmp-copilot",
          timeout_ms = async_timeout_ms,
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

    snippets = { preset = 'luasnip' },

    -- experimental signature help support
    signature = { enabled = true },
  }

  if ollama_enabled() then
    table.insert(opts.sources.default, "minuet")
    opts.sources.providers.minuet = {
      name = "Ollama",
      module = "minuet.blink",
      score_offset = 8,
      timeout_ms = async_timeout_ms,
    }
  end

  return opts
end

local function ollama_opts(select_set)
  select_set = select_set or "qwen_coder"
  local opt_sets = {
    qwen_coder = {
      blink = { enable_auto_complete = true },
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          name = "Qwen 2.5 Coder",
          -- The endpoint may return a 404 if the given model is not found
          model = "qwen2.5-coder:7b-16k",
          end_point = OLLAMA_BASE_URL .. "/v1/chat/completions",
          api_key = "TERM",
          stream = true,
          optional = {
            stop = nil,
            max_tokens = nil,
          },
        },
      },
    },
    deepseek_r1 = {
      blink = { enable_auto_complete = true },
      provider = "openai_compatible",
      provider_options = {
        openai_compatible = {
          name = "Deepseek R1",
          -- The endpoint may return a 404 if the given model is not found
          model = "deepseek-r1:32b-8k",
          end_point = OLLAMA_BASE_URL .. "/v1/chat/completions",
          api_key = "TERM",
          stream = true,
          optional = {
            stop = nil,
            max_tokens = nil,
          }
        }
      }
    }
  }
  return opt_sets[select_set]
end

function M.blink_deps()
  local deps = {
    "folke/lazydev.nvim",
    "giuxtaposition/blink-cmp-copilot",
    "zbirenbaum/copilot.lua",
    "L3MON4D3/LuaSnip",
  }
  if ollama_enabled() then
    deps[#deps + 1] = "milanglacier/minuet-ai.nvim"
  end
  return deps
end

---@alias symbolUsageFormatter {setup: fun(), text_format: fun(symbol: table): (string | string[])}
---@type table<string, symbolUsageFormatter>
local codelens_formatters = {
  -- sourced from https://github.com/Wansmer/symbol-usage.nvim?tab=readme-ov-file#plain-text
  plain = {
    setup = function() end,
    text_format = function(symbol)
      local fragments = {}

      -- Indicator that shows if there are any other symbols in the same line
      local stacked_functions = symbol.stacked_count > 0
          and (' | +%s'):format(symbol.stacked_count)
          or ''

      if symbol.references then
        local usage = symbol.references <= 1 and 'usage' or 'usages'
        local num = symbol.references == 0 and 'no' or symbol.references
        table.insert(fragments, ('%s %s'):format(num, usage))
      end

      if symbol.definition then
        table.insert(fragments, symbol.definition .. ' defs')
      end

      if symbol.implementation then
        table.insert(fragments, symbol.implementation .. ' impls')
      end

      return table.concat(fragments, ', ') .. stacked_functions
    end,
  },
  -- sourced from https://github.com/Wansmer/symbol-usage.nvim?tab=readme-ov-file#bubbles
  bubbles = {
    setup = function()
      -- gets highlight groups from the current buffer
      local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end

      -- hl-groups can have any name
      vim.api.nvim_set_hl(0, 'SymbolUsageRounding', { fg = h('CursorLine').bg, italic = true })
      vim.api.nvim_set_hl(0, 'SymbolUsageContent', { bg = h('CursorLine').bg, fg = h('Comment').fg, italic = true })
      vim.api.nvim_set_hl(0, 'SymbolUsageRef', { fg = h('Function').fg, bg = h('CursorLine').bg, italic = true })
      vim.api.nvim_set_hl(0, 'SymbolUsageDef', { fg = h('Type').fg, bg = h('CursorLine').bg, italic = true })
      vim.api.nvim_set_hl(0, 'SymbolUsageImpl', { fg = h('@keyword').fg, bg = h('CursorLine').bg, italic = true })
    end,
    text_format = function(symbol)
      local res = {}

      local round_start = { '', 'SymbolUsageRounding' }
      local round_end = { '', 'SymbolUsageRounding' }

      -- Indicator that shows if there are any other symbols in the same line
      local stacked_functions_content = symbol.stacked_count > 0
          and ("+%s"):format(symbol.stacked_count)
          or ''

      if symbol.references then
        local usage = symbol.references <= 1 and 'usage' or 'usages'
        local num = symbol.references == 0 and 'no' or symbol.references
        table.insert(res, round_start)
        table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
        table.insert(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
        table.insert(res, round_end)
      end

      if symbol.definition then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
        table.insert(res, { symbol.definition .. ' defs', 'SymbolUsageContent' })
        table.insert(res, round_end)
      end

      if symbol.implementation then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
        table.insert(res, { symbol.implementation .. ' impls', 'SymbolUsageContent' })
        table.insert(res, round_end)
      end

      if stacked_functions_content ~= '' then
        if #res > 0 then
          table.insert(res, { ' ', 'NonText' })
        end
        table.insert(res, round_start)
        table.insert(res, { ' ', 'SymbolUsageImpl' })
        table.insert(res, { stacked_functions_content, 'SymbolUsageContent' })
        table.insert(res, round_end)
      end

      return res
    end,
  }
}

function M.packages(use)
  use 'neovim/nvim-lspconfig'
  use { 'williamboman/mason.nvim', version = '^1.0.0' }
  use { 'williamboman/mason-lspconfig.nvim', version = '^1.0.0', config = mason_config }
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
    opts = M.blink_opts(),
    opts_extend = { "sources.default" },
    dependencies = M.blink_deps(),
  }

  use {
    "milanglacier/minuet-ai.nvim",
    cond = ollama_enabled(),
    opts = ollama_opts(),
    dependencies = { "nvim-lua/plenary.nvim" },
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
  vim.lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or "warn")

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
