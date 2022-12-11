local M = {}

M.packages = {
  Package:new{'https://github.com/rafamadriz/friendly-snippets.git'};
  Package:new{'honza/vim-snippets'};
  Package:new{'https://github.com/molleweide/LuaSnip-snippets.nvim.git'};
  Package:new{
    'https://github.com/L3MON4D3/LuaSnip.git',
    tag = 'v1.*',
    config = function()
      local ok, ls = pcall(require, 'luasnip')
      if not ok then
        return
      end
      ls.config.setup{
        -- When false you cannot jump back into a snippet once it is complete.
        -- Turning it off lets the snippet function exit after you are done.
        -- This prevents the plugin or keybinds from conflicting.
        history = false;
      }
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load()
      --ls.snippets = require("luasnip-snippets").load_snippets()
      vim.cmd([[
        " press <Tab> to expand or jump in a snippet. These can also be mapped separately
        " via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
        ""imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
        " -1 for jumping backwards.
        ""inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

        snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
        snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
      ]])
    end,
  };
}

return M
