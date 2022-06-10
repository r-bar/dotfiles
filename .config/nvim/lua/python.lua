local M = {}
local set = vim.api.nvim_set_var

M.packages = {
  --Package:new{
  --  'https://github.com/vim-python/python-syntax.git',
  --  config = function() set('python_highlight_all', 1) end,
  --},
  Package:new{'https://github.com/Vimjas/vim-python-pep8-indent.git'},
  -- provides python text objects (can probably be removed when treesitter works)
  --Package:new{'https://github.com/jeetsukumaran/vim-pythonsense.git'},
  Package:new{'Glench/Vim-Jinja2-Syntax'},
}

function M.lsp_callback(options)

  -- Get the command for the pylsp server. This implementation builds a command
  -- for docker / podman. API compatable with LSP containers.
  -- https://github.com/lspcontainers/lspcontainers.nvim/tree/3c9d2156a447eb111ec60f4358768eb7510c5d0d#additional-languages
  local function pylsp_cmd(runtime, workdir, image, pylsp_options)
    local pylsp_config = require('lspconfig/server_configurations/pylsp').default_config
    local lspconfig_utils = require 'lspconfig.util'
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    -- get a sane working directory to mount if one is not set
    -- first branch implementation adapted from:
    -- https://github.com/neovim/nvim-lspconfig/blob/84252b08b7f9831b0b1329f2a90ff51dd873e58f/lua/lspconfig/configs.lua#L80-L88
    if workdir == nil and lspconfig_utils.bufname_valid(bufname) then
      workdir = pylsp_config.root_dir(lspconfig_utils.path.sanitize(bufname))
    end
    -- fallback to using the editor's working directory to determine the root
    -- path
    if workdir == nil then
      workdir = pylsp_config.root_dir(vim.env.PWD) or vim.env.PWD
    end

    if runtime == nil then
      runtime = options.containers.container_runtime
    end

    if image == nil then
      image = 'registry.barth.tech/library/pylsp:latest'
    end

    if pylsp_options == nil then
      pylsp_options = {}
    end

    local container_options = {'--interactive', '--rm', '--volume', workdir..':'..workdir, '--workdir', workdir}
    if vim.env.VIRTUAL_ENV then
      vim.list_extend(container_options, {'--volume', vim.env.VIRTUAL_ENV .. ':/venv'})
    end

    local cmd = {runtime, 'container', 'run'}
    vim.list_extend(cmd, container_options)
    table.insert(cmd, image)
    vim.list_extend(cmd, pylsp_options)

    return cmd
  end

  return {
    pylsp = {
      cmd = pylsp_cmd();
      -- the on_new_config callback is invoked everytime lspconfig calculates a
      -- new root directory for an opened buffer
      on_new_config = function(new_config, root_dir)
        new_config.cmd = pylsp_cmd(nil, root_dir, nil, {'--log-file', '/workdir/lsp.log', '-v'})
      end;
    }
  }
end

return M
