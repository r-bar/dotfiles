-- Configuration for text auto completion

local M = {}
local OLLAMA_BASE_URL = "http://earth.ts.barth.tech:11434"


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

function M.packages(use)
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
      require("luasnip.loaders.from_lua").load()
    end,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'honza/vim-snippets',
      'https://github.com/molleweide/LuaSnip-snippets.nvim.git',
    },
  }

  -- LLM based auto completion
  use {
    "zbirenbaum/copilot.lua",
    cond = vim.env.DISABLE_COPILOT == nil,
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        trigger_characters = { ".", ":", " ", "\t" },
      },
      panel = { enabled = true },
    }
  }

  use {
    "milanglacier/minuet-ai.nvim",
    cond = ollama_enabled,
    opts = ollama_opts(),
    dependencies = { "nvim-lua/plenary.nvim" },
  }
end

return M
