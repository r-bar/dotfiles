-- Runtime configuration via environment variables.

local M = {}

M.AI_AGENT = vim.env.NVIM_AI_AGENT
M.DISABLE_COPILOT = vim.env.DISABLE_COPILOT
M.LSP_LOG_LEVEL = vim.env.NVIM_LSP_LOG_LEVEL
M.PYTHON = vim.env.NVIM_PYTHON
M.PYTHON_TYPE_CHECKER = vim.env.NVIM_PYTHON_TYPE_CHECKER

return M
