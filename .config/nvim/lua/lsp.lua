local M = {}

-- Global lsp server options
M.options = {
  -- options for lspcontainers, not part of actual lspconfig setup arguments
  containers = {container_runtime = vim.env.LSP_CONTAINER_RUNTIME or 'podman'}
}

-- Global on_attach callback
function M.options.on_attach(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local keymap_opts = { noremap = true, silent = true }
    -- Set some keybinds conditional on server capabilities
    if (
      client.resolved_capabilities.document_formatting
      or client.resolved_capabilities.document_range_formatting
    ) then
      buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting{timeout_ms=5000}<CR>", keymap_opts)
    end

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
      vim.api.nvim_exec([[
        augroup lsp_document_highlight
          autocmd!
          autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]], false)
    end
end

-- callback should take options table and return a table of server names and
-- their lspconfig arguments
function M.initialize(callback)
  return callback(M.options)
end

-- Merge any global options with server specific options
function M.merge_args(args)
  local base_args = {}

  local cmp_nvim_lsp_installed, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if cmp_nvim_lsp_installed then
    -- Set up capabilities for cmp_nvim.
    --base_args.capabilities = cmp_nvim_lsp.update_capabilities(
    --  vim.lsp.protocol.make_client_capabilities()
    --)
    base_args.capabilities = cmp_nvim_lsp.default_capabilities()
  end

  if args.on_attach == nil then
    base_args.on_attach = M.on_attach
  else
    function base_args.on_attach(client, bufnr)
      M.options.on_attach(client, bufnr)
      args.on_attach(client, bufnr)
    end
  end
  return vim.tbl_extend('keep', base_args, args)
end

return M
