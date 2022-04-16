local config = require('utils').Config:new()
local Package = require('utils').Package
local LSP_CONTAINER_OPTIONS = {container_runtime = vim.env.LSP_CONTAINER_RUNTIME or 'podman'}

config.packages = {
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
  Package:new{'https://github.com/lspcontainers/lspcontainers.nvim.git'};
}

function config.config()
  local lspcontainers = require 'lspcontainers'

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

  --vim.lsp.set_log_level("debug")

  local lspconfig = require 'lspconfig'
  local configs = require 'lspconfig/configs'

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true }
      -- Set some keybinds conditional on server capabilities
    if client.resolved_capabilities.document_formatting then
      buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    elseif client.resolved_capabilities.document_range_formatting then
      buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
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

  local servers = {
    rust_analyzer = {
      on_attach = on_attach;
      settings = {
        ["rust-analyzer"] = {
          cargo = { loadOutDirsFromCheck = true };
          procMacro = { enable = true };
          updates = { channel = "nightly" };
        };
      };
    };
    tsserver = {
      on_attach = on_attach;
      before_init = function(params)
        params.processId = vim.NIL
      end;
      cmd = lspcontainers.command('tsserver', LSP_CONTAINER_OPTIONS);
      --root_dir = util.root_pattern(".git", vim.fn.getcwd());
    };
    vimls = { on_attach = on_attach };
    yamlls = {
      on_attach = on_attach;
      cmd = lspcontainers.command('yamlls', LSP_CONTAINER_OPTIONS)
    };
    jsonls = {
      cmd = { "json-languageserver", "--stdio" };
      on_attach = on_attach;
    };
    html = { on_attach = on_attach };
    bashls = { on_attach = on_attach , cmd = lspcontainers.command('bashls', LSP_CONTAINER_OPTIONS) };
    --jedi_language_server = { on_attach = on_attach };
    -- main config file for efm is at ~/.config/efm-langserver/config.yaml
    --efm = {
    --  init_options = {
    --    server_capabilities = {
    --      documentFormatting = true;
    --      diagnostics = true;
    --      documentSymbol = false;
    --      definition = false;
    --    };
    --  };
    --  filetypes = {"python"};
    --};
    sumneko_lua = {
      cmd = lspcontainers.command('sumneko_lua', LSP_CONTAINER_OPTIONS);
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

  if vim.fn.executable('pylsp') then
    servers.pylsp = { on_attach = on_attach }
  else
    servers.pylsp = { on_attach = on_attach, cmd = lspcontainers.command('pylsp', LSP_CONTAINER_OPTIONS) };
  end

  for lsp, args in pairs(servers) do
    lspconfig[lsp].setup(args)
  end

end

return config
