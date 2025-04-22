----@type ConfigPkg
local M = {}

function M.packages(use)
  use 'LnL7/vim-nix'
  use "https://github.com/coddingtonbear/confluencewiki.vim"
  use {
    "https://github.com/towolf/vim-helm.git",
    config = function()
      vim.api.nvim_create_autocmd(
        { "BufNewFile", "BufRead" },
        {
          pattern = {
            "*/templates/*.yaml",
            "*/templates/*.yml",
            "*/templates/*.tpl",
            "*.gotmpl",
            "helmfiles.yaml",
          },
          callback = function()
            vim.opt_local.filetype = "helm"
            vim.lsp.stop_client({ 'yamlls' })
          end,
        }
      )
    end,
  }
  use { "https://github.com/google/vim-jsonnet.git", ft = "jsonnet" }
  use { "https://github.com/r-bar/ebnf.vim.git", ft = "ebnf" }
  use { "https://github.com/cespare/vim-toml.git", ft = "toml" }
  use "https://github.com/chr4/nginx.vim.git"
  use { 'https://github.com/digitaltoad/vim-pug.git', ft = 'pug' }
  use { "https://github.com/ollykel/v-vim.git", ft = 'vlang' }
  use { "https://github.com/IndianBoy42/tree-sitter-just.git", ft = 'just', config = true }
  use "https://github.com/pearofducks/ansible-vim.git"
  use { "czheo/mojo.vim", ft = 'mojo' }
  use { 'https://github.com/Vimjas/vim-python-pep8-indent.git', ft = "python" }
  use 'Glench/Vim-Jinja2-Syntax'
  use 'https://github.com/alker0/chezmoi.vim.git'
  use 'https://github.com/mracos/mermaid.vim.git'
end

local function is_helm_file(path)
  local check = vim.fs.find("Chart.yaml", { path = vim.fs.dirname(path), upward = true })
  return not vim.tbl_isempty(check)
end

---@private
---@param path string
---@param bufname string
---@return string
local function yaml_filetype(path, bufname)
  return is_helm_file(path) and "helm.yaml" or "yaml"
end

---@private
---@param path string
---@param bufname string
---@return string
local function tmpl_filetype(path, bufname)
  return is_helm_file(path) and "helm.tmpl" or "template"
end

---@private
---@param path string
---@param bufname string
---@return string
local function tpl_filetype(path, bufname)
  return is_helm_file(path) and "helm.tmpl" or "smarty"
end

function M.config()
  -- By manually overriding the filetype, I prevent the yamlls server from
  -- attaching to helm yaml template files.
  -- https://www.reddit.com/r/neovim/comments/12ub997/comment/jhvddki/
  vim.filetype.add({
    extension = {
      yaml = yaml_filetype,
      yml = yaml_filetype,
      tmpl = tmpl_filetype,
      tpl = tpl_filetype
    },
    filename = {
      ["Chart.yaml"] = "yaml",
      ["Chart.lock"] = "yaml",
    }
  })
end

return M
