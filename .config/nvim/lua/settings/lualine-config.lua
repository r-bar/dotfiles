local M = {}

M.packages = {
  Package:new { 'https://github.com/nvim-lua/lsp-status.nvim.git' },
  -- required for lualine
  Package:new {
    'https://github.com/kyazdani42/nvim-web-devicons.git',
    config = function()
      require('nvim-web-devicons').setup {}
    end,
  },
  Package:new { 'https://github.com/nvim-lualine/lualine.nvim.git' },
}

function M.git_status()
  bufnr = bufnr or 0
  -- samples: "[Git:3c477c6(master)]" "[Git(master)]"
  local fugitive = vim.fn.FugitiveStatusline()
  if fugitive == nil or fugitive == "" then
    return ""
  end

  local commit, branch = require('utils').parse_fugitive_status(fugitive)
  if commit == nil and branch == nil then
    return fugitive
  elseif commit == "" then
    return branch
  else
    -- sample: "3c477c6:master"
    return string.format("%s:%s", commit, branch)
  end
end

function M.zoom_status()
  local status_fn = vim.fn['zoom#statusline']
  if status_fn ~= nil then
    return status_fn()
  end
end

function M.config()
  vim.o.cmdheight = 2

  local filename = { 'filename', path = 1 }

  require('lualine').setup {
    options = {
      theme = 'auto',
      icons_enabled = false,
      --component_separators = { left = '>', right = '<'},
      --component_separators = { left = '|', right = '|'},
      component_separators = { left = '', right = '' },
      --section_separators = { left = '⯈', right = '⯇'},
      --section_separators = { left = '', right = ''},
      --section_separators = { left = '◣', right = '◢'},
      section_separators = { left = '▶', right = '◀' },
    },
    sections = {
      lualine_a = { { 'mode', fmt = function(str) return str:sub(1, 1) end } },
      lualine_b = { M.git_status, 'diff' },
      lualine_c = { filename, M.zoom_status },
      lualine_x = { require('lsp-status').status, 'diagnostics' },
      --lualine_x = {'diagnostics'},
      lualine_y = { 'encoding', 'fileformat', 'filetype' },
      lualine_z = { 'progress', 'location' },
    },
    extensions = { 'quickfix', 'fzf', 'fugitive' },
    inactive_sections = {
      lualine_a = {},
      lualine_b = { M.git_status, filename },
      lualine_c = {},
      lualine_x = {},
      lualine_y = { 'location' },
      lualine_z = {}
    },
  }
end

return M
