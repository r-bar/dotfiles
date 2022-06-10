local M = {}
local set = vim.api.nvim_set_var

M.packages = {
  Package:new{'https://github.com/rust-lang/rust.vim.git', enabled = false},
  Package:new{'https://github.com/cespare/vim-toml.git', ['for'] = 'toml'},
}

function M.config()
  set('tagbar_type_rust', {
    ctagstype = 'rust',
    kinds = {
      'T:types,type definitions',
      'f:functions,function definitions',
      'g:enum,enumeration names',
      's:structure names',
      'm:modules,module names',
      'c:consts,static constants',
      't:traits,traits',
      'i:impls,trait implementations',
    }
  })
  set('rustfmt_autosave', 1)
end

return M
