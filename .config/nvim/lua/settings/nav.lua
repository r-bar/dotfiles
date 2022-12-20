local M = {}

M.packages = {
  Package:new{
    "https://github.com/ThePrimeagen/harpoon.git",
    config = function()
      local mark  = require("harpoon.mark")
      local ui  = require("harpoon.ui")

      vim.keymap.set("n", "<leader>m", mark.add_file)
      vim.keymap.set("n", "<leader>o", ui.nav_next)
      vim.keymap.set("n", "<leader>i", ui.nav_prev)
      vim.keymap.set("n", "<leader>p", ui.toggle_quick_menu, {noremap = true})
      vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu, {noremap = true})

      vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, {noremap = true})
      vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, {noremap = true})
      vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, {noremap = true})
      vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, {noremap = true})

      require('harpoon').setup({ save_on_toggle = true })
    end,
  },
  Package:new{
    "junegunn/fzf.vim",
    ["do"] = function() vim.fn["fzf#install"]() end,
    config = function()
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
  };
}

return M
