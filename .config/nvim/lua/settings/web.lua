local M = {}
local set = vim.api.nvim_set_var

M.packages = {
  Package:new{
    'mattn/emmet-vim',
    ['for'] = {'html', 'liquid', 'eruby', 'typescript', 'javascript', 'reason', 'jinja.html'},
    config = function()
      vim.api.nvim_exec([[
      " remap emmet trigger key to not interfere with ycm / deoplete
      let g:user_emmet_install_global = 1
      let g:user_emmet_leader_key='<C-e>'
      "imap   <C-e><C-e>   <C-o>:<plug>(emmet-expand-abbr)<CR>
      "imap   <C-e>;   <C-o>:<plug>(emmet-expand-word)<CR>
      "imap   <C-e>u   <C-o>:<plug>(emmet-update-tag)<CR>
      "imap   <C-e>d   <C-o>:<plug>(emmet-balance-tag-inward)<CR>
      "imap   <C-e>D   <C-o>:<plug>(emmet-balance-tag-outward)<CR>
      "imap   <C-e>n   <C-o>:<plug>(emmet-move-next)<CR>
      "imap   <C-e>N   <C-o>:<plug>(emmet-move-prev)<CR>
      "imap   <C-e>i   <C-o>:<plug>(emmet-image-size)<CR>
      "imap   <C-e>/   <C-o>:<plug>(emmet-toggle-comment)<CR>
      "imap   <C-e>j   <C-o>:<plug>(emmet-split-join-tag)<CR>
      "imap   <C-e>k   <C-o>:<plug>(emmet-remove-tag)<CR>
      "imap   <C-e>a   <C-o>:<plug>(emmet-anchorize-url)<CR>
      "imap   <C-e>A   <C-o>:<plug>(emmet-anchorize-summary)<CR>
      "imap   <C-e>m   <C-o>:<plug>(emmet-merge-lines)<CR>
      "imap   <C-e>c   <C-o>:<plug>(emmet-code-pretty)<CR>
      ]], false)
    end,
  },
  Package:new{'mustache/vim-mustache-handlebars'},
  Package:new{'https://github.com/pangloss/vim-javascript.git', ['for'] = {'javascript', 'html'}},
  Package:new{'https://github.com/isRuslan/vim-es6.git', ['for'] = {'javascript', 'html'}},
  Package:new{'https://github.com/chr4/nginx.vim.git'},
  Package:new{
    'https://github.com/iamcco/markdown-preview.nvim.git',
    ['for'] = 'markdown',
    config = function()
      -- set to 1, nvim will open the preview window after entering the markdown buffer
      -- default: 0
      set('mkdp_auto_start', 0)

      -- set to 1, the nvim will auto close current preview window when change
      -- from markdown buffer to another buffer
      -- default: 1
      set('mkdp_auto_close', 1)

      -- set to 1, the vim will refresh markdown when save the buffer or
      -- leave from insert mode, default 0 is auto refresh markdown as you edit or
      -- move the cursor
      -- default: 0
      set('mkdp_refresh_slow', 0)

      -- set to 1, the MarkdownPreview command can be use for all files,
      -- by default it can be use in markdown file
      -- default: 0
      set('mkdp_command_for_global', 0)

      -- set to 1, preview server available to others in your network
      -- by default, the server listens on localhost (127.0.0.1)
      -- default: 0
      set('mkdp_open_to_the_world', 0)

      -- use custom IP to open preview page
      -- useful when you work in remote vim and preview on local browser
      -- more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
      -- default empty
      set('mkdp_open_ip', '')

      -- specify browser to open preview page
      -- default: ''
      set('mkdp_browser', '')

      -- set to 1, echo preview page url in command line when open preview page
      -- default is 0
      set('mkdp_echo_preview_url', 0)

      -- a custom vim function name to open preview page
      -- this function will receive url as param
      -- default is empty
      set('mkdp_browserfunc', '')

      -- options for markdown render
      -- mkit: markdown-it options for render
      -- katex: katex options for math
      -- uml: markdown-it-plantuml options
      -- maid: mermaid options
      -- disable_sync_scroll: if disable sync scroll, default 0
      -- sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
      --   middle: mean the cursor position alway show at the middle of the preview page
      --   top: mean the vim top viewport alway show at the top of the preview page
      --   relative: mean the cursor position alway show at the relative positon of the preview page
      -- hide_yaml_meta: if hide yaml metadata, default is 1
      -- sequence_diagrams: js-sequence-diagrams options
      set('mkdp_preview_options', {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = 'middle',
        hide_yaml_meta = 1,
        sequence_diagrams = {},
      })

      -- use a custom markdown style must be absolute path
      set('mkdp_markdown_css', '')

      -- use a custom highlight style must absolute path
      set('mkdp_highlight_css', '')

      -- use a custom port to start server or random for empty
      set('mkdp_port', '')

      -- preview page title
      -- ${name} will be replace with the file name
      set('mkdp_page_title', '「${name}」')

      -- mappings
      --nmap <C-s> <Plug>MarkdownPreview
      --nmap <M-s> <Plug>MarkdownPreviewStop
      --nmap <C-p> <Plug>MarkdownPreviewToggle
    end,
  },
  Package:new{'https://github.com/digitaltoad/vim-pug.git', ['for'] = 'pug'},
  Package:new{'https://github.com/leafgarland/typescript-vim.git', ['for'] = 'typescript'},
  Package:new{'reasonml-editor/vim-reason-plus'},
  Package:new{'https://github.com/mxw/vim-jsx.git'},
  Package:new{
    'https://github.com/alvan/vim-closetag.git',
    enabled = false,
    config = function()
      -- filenames like *.xml, *.html, *.xhtml, ...
      -- These are the file extensions where this plugin is enabled.
      --
      vim.g.closetag_filenames = '*.html,*.xhtml,*.phtml,*.html.j2,*.xhtml.j2'

      -- filenames like *.xml, *.xhtml, ...
      -- This will make the list of non-closing tags self-closing in the specified files.
      --
      vim.g.closetag_xhtml_filenames = '*.xhtml,*.jsx'

      -- filetypes like xml, html, xhtml, ...
      -- These are the file types where this plugin is enabled.
      --
      vim.g.closetag_filetypes = 'html,xhtml,phtml,jinja'

      -- filetypes like xml, xhtml, ...
      -- This will make the list of non-closing tags self-closing in the specified files.
      --
      vim.g.closetag_xhtml_filetypes = 'xhtml,jsx'

      -- integer value [0|1]
      -- This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
      --
      vim.g.closetag_emptyTags_caseSensitive = 1

      -- dict
      -- Disables auto-close if not in a "valid" region (based on filetype)
      --
      vim.g.closetag_regions = {
        ['typescript.tsx'] = 'jsxRegion,tsxRegion',
        ['javascript.jsx'] = 'jsxRegion',
        ['typescriptreact'] = 'jsxRegion,tsxRegion',
        ['javascriptreact'] = 'jsxRegion',
      }

      -- Shortcut for closing tags, default is '>'
      --
      vim.g.closetag_shortcut = '>'

      -- Add > at current position without closing the current tag, default is ''
      --
      vim.g.closetag_close_shortcut = '<leader>>'
    end,
  },
  Package:new{
    'https://github.com/windwp/nvim-ts-autotag.git',
    enabled = false,
    config = function()
      require('nvim-ts-autotag').setup{
        filetypes = {
          'html',
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
          'svelte',
          'vue',
          'tsx',
          'jsx',
          'rescript',
          'xml',
          'php',
          'markdown',
          'glimmer',
          'handlebars',
          'hbs',
          'jinja',
        }
      }
    end,
  },
  Package:new{
    'https://github.com/jiangmiao/auto-pairs.git',
    enabled = false,
    config = function()
      vim.api.nvim_create_autocmd({"FileType"}, {
        pattern = {"*.py"},
        callback = function()
          -- local python_pairs = {}
          vim.b.AutoPairs = vim.tbl_extend("force", vim.g.AutoPairs, {
            ["f'"] = "'",
            ['f"'] = '"',
            ["r'"] = "'",
            ['r"'] = '"',
            ["b'"] = "'",
            ['b"'] = '"',
          })
        end,
      })
      --vim.api.nvim_create_autocmd({"FileType"}, {
      --  pattern = {"*.html", "*.md", "*.html.j2"},
      --  callback = function()
      --    -- local python_pairs = {}
      --    vim.b.AutoPairs = vim.tbl_extend("force", vim.g.AutoPairs, {
      --      ["<div>"] = "</div>",
      --    })
      --  end,
      --})
    end,
  },
}

return M
