local M = {}

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
  local lspcontainers = require 'lspcontainers'

  local pylsp = lspcontainers.configure('pylsp', require('lsp').options.containers)

  return {
    pylsp = {
      cmd = pylsp.cmd;
      -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
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
      -- the on_new_config callback is invoked everytime lspconfig calculates a
      -- new root directory for an opened buffer
      on_new_config = function(new_config, root_dir)
        local pylsp_config = LspContainersConfig.configured_servers['pylsp']
        new_config.cmd = pylsp.command(options.container_runtime, root_dir, pylsp_config.image)
      end;
    }
  }
end

return M
