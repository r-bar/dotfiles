local M = {}

M.packages = {
  -- LSP Support
  Package:new{'neovim/nvim-lspconfig'},
  Package:new{'williamboman/mason.nvim'},
  Package:new{'williamboman/mason-lspconfig.nvim'},

  -- Autocompletion
  Package:new{'hrsh7th/nvim-cmp'},
  Package:new{'hrsh7th/cmp-buffer'},
  Package:new{'hrsh7th/cmp-path'},
  Package:new{'saadparwaiz1/cmp_luasnip'},
  Package:new{'hrsh7th/cmp-nvim-lsp'},
  Package:new{'hrsh7th/cmp-nvim-lua'},

  -- Snippets
  --Package:new{'L3MON4D3/LuaSnip'},
  Package:new{'rafamadriz/friendly-snippets'},

  Package:new{'VonHeikemen/lsp-zero.nvim'},
}

--Default keybindings
--    K: Displays hover information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.hover().
--    gd: Jumps to the definition of the symbol under the cursor. See :help vim.lsp.buf.definition().
--    gD: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See :help vim.lsp.buf.declaration().
--    gi: Lists all the implementations for the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.implementation().
--    go: Jumps to the definition of the type of the symbol under the cursor. See :help vim.lsp.buf.type_definition().
--    gr: Lists all the references to the symbol under the cursor in the quickfix window. See :help vim.lsp.buf.references().
--    <Ctrl-k>: Displays signature information about the symbol under the cursor in a floating window. See :help vim.lsp.buf.signature_help(). If a mapping already exists for this key this function is not bound.
--    <F2>: Renames all references to the symbol under the cursor. See :help vim.lsp.buf.rename().
--    <F4>: Selects a code action available at the current cursor position. See :help vim.lsp.buf.code_action().

function M.config()
  local lspzero = require('lsp-zero')
  lspzero.preset('recommended')
  lspzero.setup()
  vim.keymap.set('n', '<leader>e', [[<cmd>lua vim.diagnostic.open_float()<CR>]])
end

return M
