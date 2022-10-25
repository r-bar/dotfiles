local M = {}

M.packages = {
  Package:new{'neovim/nvim-lsp'},
  Package:new{'neovim/nvim-lspconfig'},
  Package:new{'hrsh7th/cmp-nvim-lsp', config = function()
    vim.o.completeopt = [[menuone,noinsert,noselect]]
    local cmp = require('cmp')
    local luasnip = require('luasnip')

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    cmp.setup({
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          luasnip.lsp_expand(args.body) -- For `luasnip` users.
          --require('snippy').expand_snippet(args.body) -- For `snippy` users.
          --vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
      },
      window = {
        --completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
        --["<Tab>"] = cmp.mapping(function(fallback)
        --  if cmp.visible() then
        --    cmp.select_next_item()
        --  --elseif luasnip.expand_or_jumpable() then
        --    luasnip.expand_or_jump()
        --  elseif has_words_before() then
        --    cmp.complete()
        --  else
        --    fallback()
        --  end
        --end, { "i", "s" }),
        --["<S-Tab>"] = cmp.mapping(function(fallback)
        --  if cmp.visible() then
        --    cmp.select_prev_item()
        --  elseif luasnip.jumpable(-1) then
        --    luasnip.jump(-1)
        --  else
        --    fallback()
        --  end
        --end, { "i", "s" }),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        --{ name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        --{ name = 'ultisnips' }, -- For ultisnips users.
        --{ name = 'snippy' }, -- For snippy users.
      }, {
        { name = 'buffer' },
      })
    })

  end};
  Package:new{'hrsh7th/cmp-buffer'};
  Package:new{'hrsh7th/cmp-path'};
  Package:new{'hrsh7th/cmp-cmdline'};
  Package:new{'hrsh7th/nvim-cmp'};
  Package:new{'gfanto/fzf-lsp.nvim'};
  Package:new{
    'https://github.com/kosayoda/nvim-lightbulb.git';
    enabled = false;
    config = function()
      --vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]]
    end;
  };
  Package:new{'https://github.com/r-bar/lspcontainers.nvim.git'};
}

function M.config()

  vim.diagnostic.config({
    underline = true,
    signs = true,
    virtual_text = false,
    float = {
      show_header = true,
      --source = 'if_many',
      source = 'always',
      border = 'rounded',
      focusable = false,
    },
    update_in_insert = false, -- default to false
    severity_sort = false, -- default to false
  })

  local map = function(key, command)
    vim.keymap.set('n', key, command, { noremap = true, silent = true })
  end
  map('<leader>d', [[<cmd>lua vim.lsp.buf.definition()<CR>]])
  map('K',         [[<cmd>lua vim.lsp.buf.hover()<CR>]])
  map('g0',        [[<cmd>lua vim.lsp.buf.document_symbol()<CR>]])
  map('gD',        [[<cmd>lua vim.lsp.buf.implementation()<CR>]])
  map('gW',        [[<cmd>lua vim.lsp.buf.workspace_symbol()<CR>]])
  map('gd',        [[<cmd>lua vim.lsp.buf.declaration()<CR>]])
  map('gr',        [[<cmd>lua vim.lsp.buf.references()<CR>]])
  map('gs',        [[<cmd>lua vim.lsp.buf.signature_help()<CR>]])
  map('gt',        [[<cmd>lua vim.lsp.buf.type_definition()<CR>]])
  map('<leader>e', [[<cmd>lua vim.diagnostic.open_float()<CR>]])


  vim.cmd [[command LspClients :lua print(vim.inspect(vim.lsp.buf_get_clients()))]]
  vim.cmd [[command Format :lua vim.lsp.buf.format{async = false}]]
  vim.cmd [[command LspStop :lua vim.lsp.stop_client(vim.lsp.get_active_clients())]]
  vim.cmd [[command LspDiagnostics :lua vim.diagnostic.setqflist()]]

  vim.api.nvim_exec([[
  function! LspRestart()
    lua vim.lsp.buf.clear_references()
    lua vim.lsp.stop_client(vim.lsp.get_active_clients())
    edit
  endfunc
  command LspRestart :call LspRestart()
  ]], false)

  vim.lsp.set_log_level('debug')
end


function M.lsp_callback(options)
  local lspcontainers = require 'lspcontainers'

  return {
    cssls = {
      cmd = lspcontainers.command('cssls', options.containers);
    };
    tsserver = {
      before_init = function(params)
        params.processId = vim.NIL
      end;
      cmd = lspcontainers.command('tsserver', options.containers);
      --root_dir = util.root_pattern(".git", vim.fn.getcwd());
    };
    vimls = {};
    yamlls = {
      cmd = lspcontainers.command('yamlls', options.containers);
    };
    jsonls = {
      cmd = lspcontainers.command('jsonls', options.containers);
    };
    jsonnet_ls = {
      cmd = lspcontainers.command('jsonnet_ls', options.containers);
    };
    html = {
      cmd = lspcontainers.command('html', options.containers);
    };
    svelte = {
      -- There seem to be issues with the containerized version of the language
      -- server exiting early without an error. Since the svelte language server
      -- is so framework specific it is more reasonable to expect it to be part
      -- of the dev dependencies of the project. Just use the natively installed
      -- version for now.
      --cmd = lspcontainers.command('svelte', options.containers);
      cmd = {'npm', 'exec', 'svelte-language-server', '--', '--stdio'};
      --cmd = 'npm exec svelte-language-server -- --stdio';
    };
    gopls = {
      cmd = lspcontainers.command('gopls', options.containers);
    };
    dockerls = {
      cmd = lspcontainers.command('dockerls', options.containers);
    };
    graphql = {
      cmd = lspcontainers.command('graphql', options.containers);
    };
    clangd = {
      cmd = lspcontainers.command('clangd', options.containers);
    };
    bashls = {
      cmd = lspcontainers.command('bashls', options.containers);
    };
    -- haskell language server
    hls = {};

    eslint = {
      cmd = lspcontainers.command('eslint', vim.tbl_extend("force", options.containers, {
        image = 'registry.barth.tech/library/vscode-langservers:latest';
      }));
    };
    sumneko_lua = {
      cmd = lspcontainers.command('sumneko_lua', options.containers);
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT';
            -- Setup your lua path
            path = vim.split(package.path, ';');
          };
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'};
          };
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            };
          };
          -- Do not send telemetry data containing a randomized but unique identifier
          telemetry = {
            enable = false,
          };
        };
      };
    };
  }
end

return M
