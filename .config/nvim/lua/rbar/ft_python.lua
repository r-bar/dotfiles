local M = {}

function M.packages(use)
  use {'https://github.com/Vimjas/vim-python-pep8-indent.git', ft = "python"}
  use 'Glench/Vim-Jinja2-Syntax'
end

return M
