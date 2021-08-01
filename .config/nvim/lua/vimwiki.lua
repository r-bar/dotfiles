local config = require('utils').Config:new()
local Package = require('utils').Package

config.packages = {
  Package:new{'vimwiki/vimwiki', ['for'] = 'markdown', enabled = true};
}

function config.config()
  vim.g.vimwiki_global_ext = 0
  vim.g.vimwiki_list = {
    {
      path = '~/Documents/vimwiki/';
      syntax = 'markdown';
      ext = '.md';
      nested_syntaxes = {
        javascript = 'javascript';
        python = 'python';
        rust = 'rust';
        --yaml = 'yaml';
      };
    };
  }
end

return config
