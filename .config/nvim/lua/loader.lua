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
M.packer_config = {
  snapshot = "current",
  snapshot_path = vim.fn.stdpath("config") .. "/snapshots",
}
M.CURRENT_SNAPSHOT_FILE = vim.fn.stdpath("config") .. "/snapshots/current"

-- Runs the full initialization declared in any config modules. Performs the
-- following steps in order:
--
-- 1. Ensures packer is installed and loads it
-- 2. Loads all package (use) declarations
-- 3. Syncs packages if necessary
-- 4. Runs all config functions
function M.packer_init()
  local packer_bootstrap, packer = M.ensure_packer()

  --packer.set_handler("config", function(_plugins, plugin, value)
  --  local plugin_name = plugin[1]
  --  M.global_configs[plugin_name] = value
  --end)

  packer.startup{function(use)
    use "wbthomason/packer.nvim"
    for _, use_arg in pairs(M.global_uses) do
      use(use_arg)
    end
  end, config = packer_config}

  if packer_bootstrap then
    packer.sync()
  end

  for module_name, config in pairs(M.global_configs) do
    local success, err = pcall(config)
    if not success then
      print(string.format("Error running config in %s: %s", module_name, e))
    end
  end
end

function M.lazy_init()
  local opts = {defaults = { lazy = false }}
  local bootstrapped, lazy = M.ensure_lazy()

  if bootstrapped then
    lazy.sync()
  end

  lazy.setup(M.global_uses, opts)

  for module_name, config in pairs(M.global_configs) do
    local success, err = pcall(config)
    if not success then
      print(string.format("Error running config in %s: %s", module_name, e))
    end
  end
end

function M.init()
  return M.lazy_init()
end

-- Reloads all registered config modules and re-runs .init()
function M.reload()
  M.global_configs = {}
  M.global_uses = {}
  require("packer").reset()
  for _, module_name in ipairs(M.global_modules) do
    dofile(module_name)
    M.load(module_name)
  end
  M.init()
end

-- Loads packer, installing it if necessary
function M.ensure_packer()
  local installed = false
  local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd [[packadd packer.nvim]]
    installed = true
  end
  return installed, require("packer")
end

function M.ensure_lazy()
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

function M.ensure_package_manager()
  return M.ensure_lazy()
end

-- Adds packer use() arguments to a global registry to be loaded later during M.init()
function M.lazy_use(arg)
  M.global_uses[#M.global_uses+1] = arg
end

-- Add a config module name. Can be thought of like require() with extra
-- machinery for processing .packages() and .config() module functions.
-- Does not fail when a module contains an error, instead it emits an error
-- message and returns nil.
function M.load(module_name)
  M.global_modules[module_name] = true

  local success, module = pcall(require, module_name)

  if not success then
    print(string.format("Error loading %s: %s", module_name, config))
    return
  end

  if type(module.packages) == "function" then
    module.packages(M.lazy_use)
  end

  if type(module.config) == "function" then
    M.global_configs[module_name] = module.config
  end

  return module
end

-- Create a new snapshot of the current package state. Update snapshot file
-- pointers in the process.
function M.new_snapshot()
  local packer = require("packer")
  local time = vim.fn.stdftime("%s")
  local new_snapshot_path = M.packer_config.snapshot_path .. "/" .. time
  if vim.fn.executable("yadm") then
    vim.system("yadm add " .. new_snapshot_path)
  end
  packer.snapshot(time)
  vim.fn.system("ln -sf " .. new_snapshot_path .. " " .. M.CURRENT_SNAPSHOT_PATH)
end

return M
