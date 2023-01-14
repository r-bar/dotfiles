M = {}

function M.packages(use)
  use "junegunn/fzf.vim"
end

function M.config()
  vim.g.fzf_action = {
    ["ctrl-t"] = "tab split";
    ["ctrl-x"] = "split";
    ["ctrl-s"] = "split";
    ["ctrl-v"] = "vsplit";
  }
  vim.keymap.set("n", "<Leader>t", ":Files<Enter>", { silent = true })
  vim.keymap.set("n", "<Leader>b", ":Buffers<Enter>", { silent = true })
  vim.keymap.set("n", "<Leader>h", ":History<Enter>", { silent = true })
  vim.keymap.set("n", "<leader>j", ":BTags<Enter>", { silent = true })
  vim.keymap.set("n", "<leader>s", ":DocumentSymbols<Enter>", { silent = true })
  vim.keymap.set("n", "<leader>a", ":CodeActions<Enter>", { silent = true })
  vim.keymap.set("v", "<leader>a", ":RangeCodeActions<Enter>", { silent = true })
end

return M
