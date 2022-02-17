local config = require('utils').Config:new()
local Package = require('utils').Package

config.packages = {
  Package:new{
    'nvim-treesitter/nvim-treesitter',
    ['do'] = function() vim.cmd 'TSUpdate' end,
    branch = '0.5-compat',
    config = function()
      require('nvim-treesitter.configs').setup{
        ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        highlight = {
          enable = true,              -- false will disable the whole extension
          disable = {'python'},  -- list of language that will be disabled
        },
        -- bug causing issues with python indentation:
        -- https://github.com/neovim/neovim/issues/13786
        indent = { enable = true, disable = {'python', 'yaml'} },
      }
    end,
  },
  -- disabled due to apparent incompatability with new treesitter api. I believe
  -- this is the related issue:
  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/171
  --Package:new{
  --  'nvim-treesitter/nvim-treesitter-textobjects',
  --  config = function()
  --    require'nvim-treesitter.configs'.setup {
  --      textobjects = {
  --        lsp_interop = {
  --          enable = false,
  --          peek_definition_code = {
  --            ["df"] = "@function.outer",
  --            ["dF"] = "@class.outer",
  --          },
  --        },
  --        select = {
  --          enable = true,
  --          keymaps = {
  --            -- You can use the capture groups defined in textobjects.scm
  --            ["af"] = "@function.outer",
  --            ["if"] = "@function.inner",
  --            ["ac"] = "@class.outer",
  --            ["ic"] = "@class.inner",

  --            -- Or you can define your own textobjects like this
  --            ["iF"] = {
  --              --python = "(function_definition) @function",
  --              --cpp = "(function_definition) @function",
  --              --c = "(function_definition) @function",
  --              --java = "(method_declaration) @function",
  --            },
  --          },
  --        },
  --        move = {
  --          enable = true,
  --          goto_next_start = {
  --            ["]m"] = "@function.outer",
  --            ["]]"] = "@class.outer",
  --          },
  --          goto_next_end = {
  --            ["]M"] = "@function.outer",
  --            ["]["] = "@class.outer",
  --          },
  --          goto_previous_start = {
  --            ["[m"] = "@function.outer",
  --            ["[["] = "@class.outer",
  --          },
  --          goto_previous_end = {
  --            ["[M"] = "@function.outer",
  --            ["[]"] = "@class.outer",
  --          },
  --        },
  --      },
  --    }
  --  end,
  --},
  Package:new{
    'nvim-treesitter/playground',
    ['do'] = function() vim.cmd 'TSInstall query' end,
    on = 'TSPlaygroundToggle',
    config = function()
      require('nvim-treesitter.configs').setup{
        playground = {
          enable = true,
          disable = {},
          updatetime = 25,
          persist_queries = false,
        }
      }
    end,
  },
}

function config.get_tsnode()
  local bufnr = vim.fn.bufnr()
  local lang = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tstree = parser:parse()
  local row, col = vim.api.nvim_win_get_cursor(0)
  --row, col = vim.api.nvim_win_get_cursor(vim.fn.winnr())
  local node = tstree:descendant_for_range(row, col, row, col)
  --named_node = root:named_descendant_for_range(row, col, row, col)
  return node
end

function config.config()
end

return config
