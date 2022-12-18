local M = {}

M.packages = {
  Package:new { "https://github.com/rust-lang/rust.vim.git", enabled = false },
}

function M.config()
  vim.g.tagbar_type_rust = {
    ctagstype = "rust",
    kinds = {
      "T:types,type definitions",
      "f:functions,function definitions",
      "g:enum,enumeration names",
      "s:structure names",
      "m:modules,module names",
      "c:consts,static constants",
      "t:traits,traits",
      "i:impls,trait implementations",
    }
  }
  vim.g.rustfmt_autosave = 1

  require("lsp-zero").use("rust_analyzer", {
    settings = {
      ["rust-analyzer"] = {
        cargo = { loadOutDirsFromCheck = true };
        procMacro = { enable = true };
        updates = { channel = "nightly" };
        checkOnSave = { command = "clippy" };
        diagnostics = { experimental = { enable = true } };
      };
    };
  })
end

return M
