-- Provides a lazy loading module system that allows us to gather all packages
-- and configs. We do this to make sure all package declarations get called
-- before any of the config functions. This way any missing requirements or
-- errors in the configs do not prevent all packages from being read and
-- installed. Meanwhile we can group related sets of packages and their configs
-- for better organization.
-- 
-- Config modules are expected to expose .config() and / or .packages(use)
-- functions. Logic should be kept to a bare minimum inside of .packages.
local M = {
  global_configs = {},
  global_uses = {},
  global_modules = {},
}


---@alias usefn fun(spec: string | LazySpec): nil
---@class ConfigPkg
---@field packages? fun(use: usefn): nil
---@field config? fun(): nil

-- Runs the full initialization declared in any config modules. Performs the
-- following steps in order:
--
-- 1. Ensures lazy.nvim is installed and loads it
-- 2. Loads all package (use) declarations
-- 3. Syncs packages if necessary
-- 4. Runs all config functions
function M.init()
  local opts = {defaults = { lazy = false }}
  local bootstrapped, lazy = M.ensure_package_manager()

  if bootstrapped then
    lazy.sync()
  end

  lazy.setup(M.global_uses, opts)

  for module_name, config in pairs(M.global_configs) do
    config()
    --local success, err = pcall(config)
    --if not success then
    --  print(string.format("Error running config in %s: %s", module_name, e))
    --end
  end
end

-- Reloads all registered config modules and re-runs .init()
function M.reload()
  M.global_configs = {}
  M.global_uses = {}
  for _, module_name in ipairs(M.global_modules) do
    dofile(module_name)
    M.load(module_name)
  end
  M.init()
end

function M.ensure_package_manager()
  local installed = false
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  return installed, require("lazy")
end

-- Adds use() arguments to a global registry to be loaded later during M.init()
function M.lazy_use(spec)
  M.global_uses[#M.global_uses+1] = spec
end

-- Add a config module name. Can be thought of like require() with extra
-- machinery for processing .packages() and .config() module functions.
-- Does not fail when a module contains an error, instead it emits an error
-- message and returns nil.
function M.load(module_name)
  M.global_modules[module_name] = true

  local module = require(module_name)
  --local success, module = pcall(require, module_name)
  --if not success then
  --  print(string.format("Error loading %s: %s", module_name, config))
  --  return
  --end

  if type(module.packages) == "function" then
    module.packages(M.lazy_use)
  end

  if type(module.config) == "function" then
    M.global_configs[module_name] = module.config
  end

  return module
end

return M
