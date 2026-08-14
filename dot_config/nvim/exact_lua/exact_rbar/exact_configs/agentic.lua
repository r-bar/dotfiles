---@type ConfigPkg
local M = {}

--- @return string
local function default_agent()
	if vim.env.NVIM_AI_AGENT ~= nil then
		return vim.env.NVIM_AI_AGENT
	end
	if vim.fn.executable("opencode") == 1 then
		return "opencode"
	end
	if vim.fn.executable("claude") == 1 then
		return "claudecode"
	end
	return ""
end

local function this_error(context)
	local cur_line, _cur_col0 = unpack(vim.api.nvim_win_get_cursor(0))
	cur_line = cur_line - 1 -- Convert to 0-indexed
	local diags = vim.diagnostic.get(0, { lnum = cur_line })
	local this = context:this()
	-- local diagnostics = context:diagnostics()
	local line_diags = {}
	line_diags[#line_diags + 1] = string.format("Errors for %s:\n", this)
	for _, d in ipairs(diags) do
		local msg = d.message:gsub("\n", " ")
		line_diags[#line_diags + 1] = string.format("- %s\n", msg)
	end
	return table.concat(line_diags)
end

local ACP = {
	claude = "claude-agent-acp",
	opencode = "opencode-acp",
}

function M.packages(use)
	local agent = default_agent()

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
		end,
	})
end

return M
