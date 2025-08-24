---@type ConfigPkg
local M = {}

function M.packages(use)
  use {
    "r-bar/nvim-treesitter",
    branch = "gleam-fix",
    run = ":TSUpdate",
    build = ":TSUpdate",
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.pest = {
        install_info = {
          url = "https://github.com/pest-parser/tree-sitter-pest.git", -- local path or git repo
          files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
          -- optional entries:
          branch = "main", -- default branch in case of git repo if different from master
          generate_requires_npm = false, -- if stand-alone parser without npm dependencies
          requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
        },
        filetype = "pest", -- if filetype does not match the parser name
      }
      require("nvim-treesitter.configs").setup {
        -- A list of parser names, or "all"
        ensure_installed = "all",
        modules = {},
        -- List of parsers to ignore installing (for "all")
        -- ipkg ignored due to tarball extration error
        -- see: https://github.com/nvim-treesitter/nvim-treesitter/issues/4250
        ignore_install = {'ipkg'},

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
          -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
          -- the name of the parser)
          -- list of language that will be disabled
          --disable = {"sql", "verilog"},
          -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
          --disable = function(lang, buf)
          --  local disabled_languages = {'sql'}
          --  local max_filesize = 1000 * 1024 -- 1000 KB
          --  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          --  local large_file = ok and stats and stats.size > max_filesize
          --  if list_contains(lang, disabled_languages) then
          --    return true
          --  elseif large_file then
          --    return true
          --  end
          --  return false
          --end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = {"sql"},
        },
        indent = {
          enable = true,
          disable = {}
        },
        textobjects = { enable = true },
      }
    end,
    dependencies = {
      "https://github.com/pest-parser/tree-sitter-pest.git",
    },
  }
  use {
    "nvim-treesitter/playground",
    cmd = "TSPlaygroundToggle",
  }
end

return M
