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

function Config:_lsp_init()
  local lspconfig = require 'lspconfig'
  local lsp = require 'lsp'
  for _, func in ipairs(self.lsp_server_callbacks) do
    local initialize_success, err = xpcall(lsp.initialize, debug.traceback, func)
    if not initialize_success then
      print(err)
    else
      for server, base_args in pairs(lsp.initialize(func)) do
        if self.lsp_servers[server] ~= nil then
          error(string.format("%s language server configured twice", server))
        end
        self.lsp_servers[server] = lsp.merge_args(base_args)
      end
    end
  end
  for server, args in pairs(self.lsp_servers) do
    lspconfig[server].setup(args)
  end
end

-- Config modules ex
function Config:add(module)
  if module.packages ~= nil then
    vim.list_extend(self.packages, module.packages)
    --for i=1, #module.packages do
    --  self.packages[#self.packages + 1] = module.packages[i]
    --end
  end

  if module.config ~= nil then
    self.configs[#self.configs + 1] = module.config
  end

  if module.lsp_callback ~= nil then
    self.lsp_server_callbacks[#self.lsp_server_callbacks + 1] = module.lsp_callback
  end
end


M.Config = Config

return M
