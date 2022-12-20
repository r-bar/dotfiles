local M = {}

M.packages = {
  Package:new { 'https://github.com/Vimjas/vim-python-pep8-indent.git' },
  Package:new { 'Glench/Vim-Jinja2-Syntax' },
}

function M.config()
  local success, lsp = pcall(require, "lsp-zero")
  if not success then
    return
  end
  lsp.use("pylsp", {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    --on_attach = function(client, bufnr)
    --  -- https://neovim.discourse.group/t/preserve-internal-formatting-when-using-gq-motion/3159/2
    --  vim.opt.formatexpr = ""
    --end,
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
  })
end

return M
