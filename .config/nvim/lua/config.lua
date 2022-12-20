local M = {}
local Config = {}

function Config:new()
  local new = {
    packages = {};
    configs = {};
    lsp_server_callbacks = {};
    lsp_servers = {};
  }
  self.__index = self
  return setmetatable(new, self)
end

function Config:init(path)

  self:_plug_up(path)
  --self:_pack_up()
  for _, package in ipairs(self.packages) do
    package:configure()
  end
  for _, config in ipairs(self.configs) do
    config()
  end
  -- only load lspconfig module after packages have been initialized
  --self:_lsp_init()
end

function Config:_plug_up(path)
  if path == nil then
    vim.fn["plug#begin"]()
  else
    vim.fn["plug#begin"](path)
  end
  for _, package in ipairs(self.packages) do
    package:plug_up()
  end
  vim.fn["plug#end"]()
end

function Config:_pack_up()
  vim.cmd('packloadall')
  for _, package in ipairs(self.packages) do
    package:pack_up()
  end
  -- Currently .discover() does not do anything to manage package dependencies
  -- resulting in errors when we try to load all packages sequentially this way.
  for _, package in ipairs(Package.discover()) do
    package:pack_up()
  end
end

-- Config modules ex
function Config:add(module)
  if module.packages ~= nil then
    vim.list_extend(self.packages, module.packages)
  end

  if module.config ~= nil then
    self.configs[#self.configs + 1] = module.config
  end

end


M.Config = Config

return M
