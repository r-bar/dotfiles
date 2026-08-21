---@class ConfigPkg
local M = {}

--- @return string
function M.default_agent()
	local env_agent = require("rbar/environment").AI_AGENT
	if env_agent ~= nil then
		return env_agent
	end
	if vim.fn.executable("opencode") == 1 then
		return "opencode"
	end
	if vim.fn.executable("claude") == 1 then
		return "claude"
	end
	return ""
end

local ACP = {
	claude = "claude-agent-acp",
	opencode = "opencode-acp",
}

function M.packages(use)
	local agent = M.default_agent()

	use({
		"carlos-algms/agentic.nvim",
		enabled = agent ~= "",

		--- @type agentic.PartialUserConfig
		opts = {
			-- Any ACP-compatible provider works. Built-in: "claude-agent-acp" |
			-- "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" |
			-- "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" |
			-- "goose-acp" | "kiro-acp" | "pi-acp"
			provider = ACP[agent],
			-- provider = 'opencode-acp',
			windows = { width = 120 },
		},

		-- these are just suggested keymaps; customize as desired
		keys = {
			{
				"<leader>aa",
				function()
					require("agentic").toggle({ auto_add_to_context = false })
				end,
				mode = { "n", "v" },
				desc = "[Agent] Toggle Chat",
			},
			{
				"<leader>as",
				function()
					require("agentic").add_selection_or_file_to_context()
				end,
				mode = { "n", "v" },
				desc = "[Agent] Add file or selection to Context",
			},
			{
				"<leader>an",
				function()
					require("agentic").new_session()
				end,
				mode = { "n", "v" },
				desc = "[Agent] New Session",
			},
			{
				"<leader>ar",
				function()
					require("agentic").restore_session()
				end,
				desc = "[Agent] Restore session",
				silent = true,
				mode = { "n", "v" },
			},
			{
				"<leader>al",
				function()
					require("agentic").restore_session()
				end,
				desc = "[Agent] Restore LIVE session",
				silent = true,
				mode = { "n", "v" },
			},
			{
				"<leader>ad",
				function()
					require("agentic").add_current_line_diagnostics()
				end,
				desc = "[Agent] Add current line diagnostic",
				mode = { "n" },
			},
			{
				"<leader>aD",
				function()
					require("agentic").add_buffer_diagnostics()
				end,
				desc = "[Agent] Add all buffer diagnostics",
				mode = { "n" },
			},
		},
		config = function()
			local opts = {
				-- Any ACP-compatible provider works. Built-in: "claude-agent-acp" |
				-- "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" |
				-- "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" |
				-- "goose-acp" | "kiro-acp" | "pi-acp"
				provider = ACP[agent],
				-- provider = 'opencode-acp',
				windows = { width = 120 },
			}
			require("agentic").setup(opts)
			--- agentic.nvim's chat/todos/code/files/diagnostics/input buffers all use
			--- filetypes prefixed with "Agentic".
			local function is_agentic_buf(bufnr)
				return vim.bo[bufnr].filetype:match("^Agentic") ~= nil
			end

			local function equalize_windows()
				vim.cmd("wincmd =")
			end

			local group = vim.api.nvim_create_augroup("RbarAgenticEqualizeWindows", { clear = true })

			vim.api.nvim_create_autocmd("BufWinEnter", {
				group = group,
				callback = function(ev)
					if is_agentic_buf(ev.buf) then
						equalize_windows()
					end
				end,
				desc = "Agentic: equalize windows when an agentic window opens",
			})

			vim.api.nvim_create_autocmd("WinClosed", {
				group = group,
				callback = function(ev)
					local closed_winid = tonumber(ev.match)
					if not closed_winid then
						return
					end
					local ok, bufnr = pcall(vim.api.nvim_win_get_buf, closed_winid)
					if not ok or not is_agentic_buf(bufnr) then
						return
					end
					-- WinClosed fires before the window is actually removed from the
					-- layout, so equalizing here would still count it; defer instead.
					vim.schedule(equalize_windows)
				end,
				desc = "Agentic: equalize windows when an agentic window closes",
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "AgenticChat",
				callback = function(ev)
					vim.treesitter.start(ev.buf, "markdown")
				end,
			})
		end,
	})
end

return M
