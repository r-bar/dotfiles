local M = {}

-- Global lsp server options
M.options = {
  -- options for lspcontainers, not part of actual lspconfig setup arguments
  containers = {container_runtime = vim.env.LSP_CONTAINER_RUNTIME or 'podman'}
}

M.packages = {
  Package:new{'neovim/nvim-lsp'},
  Package:new{'neovim/nvim-lspconfig'},
  Package:new{'https://github.com/hrsh7th/nvim-compe.git', config = function()
    vim.o.completeopt = [[menuone,noinsert,noselect]]

    require'compe'.setup {
      enabled = true;
      debug = false;
      min_length = 1;
      preselect = 'disable'; -- 'enable' || 'disable' || 'always'
      throttle_time = 80;
      source_timeout = 200;
      resolve_timeout = 800;
      incomplete_delay = 400;
      max_abbr_width = 100;
      max_kind_width = 100;
      max_menu_width = 100;
      documentation = true;
      allow_prefix_unmatch = false;

      source = {
        path = true;
        buffer = true;
        --vsnip = true;
        ultisnips = true;
        nvim_lsp = true;
      };
    }

    vim.cmd [[inoremap <silent><expr> <C-Space> compe#complete()]]
    vim.cmd [[inoremap <silent><expr> <CR>      compe#confirm('<CR>')]]
    vim.cmd [[inoremap <silent><expr> <C-e>     compe#close('<C-e>')]]

  end};
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
  --vim.cmd [[imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"]]
  --vim.cmd [[imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"]]
  vim.api.nvim_set_keymap('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
  vim.api.nvim_set_keymap('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
  --let g:SuperTabDefaultCompletionType = '<c-n>'

  -- leave <c-]> as mapping for ctags based lookup
  --vim.cmd [[nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>]]
  --vim.cmd [[nnoremap <silent> <leader>d <cmd>lua vim.lsp.buf.definition()<CR>]]
  --vim.cmd [[nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>]]
  --vim.cmd [[nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>]]
  --vim.cmd [[nnoremap <silent> gs    <cmd>lua vim.lsp.buf.signature_help()<CR>]]
  --vim.cmd [[nnoremap <silent> gt    <cmd>lua vim.lsp.buf.type_definition()<CR>]]
  --vim.cmd [[nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>]]
  --vim.cmd [[nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>]]
  --vim.cmd [[nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>]]
  --vim.cmd [[nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>]]

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
    vim.api.nvim_set_keymap('n', key, command, { noremap = true, silent = true })
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
  vim.cmd [[command Format :lua vim.lsp.buf.formatting_sync(nil, 5000)]]
  vim.cmd [[command LspStop :lua vim.lsp.stop_client(vim.lsp.get_active_clients())]]
  vim.cmd [[command LspDiagnostics :lua vim.lsp.diagnostic.set_loclist()]]

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

  local function eslint_cmd(runtime, workdir, image)
    local base_config = require 'lspconfig.server_configurations.eslint'
    local base_cmd = base_config.default_config.cmd

    if image == nil then
      image = 'registry.barth.tech/library/vscode-langservers:latest'
    end
    if runtime == nil then
      runtime = options.containers.container_runtime
    end
    if workdir == nil then
      workdir = base_config.default_config.root_dir(vim.env.PWD)
    end

    local cmd = {runtime, 'run', '--rm', '-i', '-v', workdir..':'..workdir, '-w', workdir, image}
    vim.list_extend(cmd, base_cmd)
    return cmd
  end

  return {
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { loadOutDirsFromCheck = true };
          procMacro = { enable = true };
          updates = { channel = "nightly" };
        };
      };
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
        cmd_builder = eslint_cmd;
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


-- Global on_attach callback
function M.options.on_attach(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local keymap_opts = { noremap = true, silent = true }
    -- Set some keybinds conditional on server capabilities
    if (
      client.resolved_capabilities.document_formatting
      or client.resolved_capabilities.document_range_formatting
    ) then
      buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting{timeout_ms=5000}<CR>", keymap_opts)
    end

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
      vim.api.nvim_exec([[
        augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]], false)
    end
end

-- callback should take options table and return a table of server names and
-- their lspconfig arguments
function M.initialize(callback)
  return callback(M.options)
end

-- Merge any global options with server specific options
function M.merge_args(args)
  local base_args = {}
  if args.on_attach == nil then
    base_args.on_attach = M.on_attach
  else
    function base_args.on_attach(client, bufnr)
      M.options.on_attach(client, bufnr)
      args.on_attach(client, bufnr)
    end
  end
  return vim.tbl_extend('keep', base_args, args)
end

return M
