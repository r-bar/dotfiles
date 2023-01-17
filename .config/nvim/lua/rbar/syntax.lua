local M = {}

function M.packages(use)
  use 'LnL7/vim-nix'
  use 'IndianBoy42/tree-sitter-just'
  use "https://github.com/coddingtonbear/confluencewiki.vim"
  use "https://github.com/towolf/vim-helm.git"
  use "https://github.com/google/vim-jsonnet.git"
  use "https://github.com/r-bar/ebnf.vim.git"
  use { "https://github.com/cespare/vim-toml.git", ft = "toml" }
  use "https://github.com/chr4/nginx.vim.git"
  use {'https://github.com/digitaltoad/vim-pug.git', ft = 'pug'}
end

return M
