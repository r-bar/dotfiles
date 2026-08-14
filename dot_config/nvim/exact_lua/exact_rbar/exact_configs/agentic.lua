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
	})
	use({
		"coder/claudecode.nvim",
		enabled = false,
		-- enabled = vim.fn.executable("claude") == 1,
		dependencies = { "folke/snacks.nvim" },
		config = true,
		-- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
		-- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
		-- spec defers loading until a <leader>a* mapping is pressed and the commands
		-- would not exist yet.
		cmd = {
			"ClaudeCode",
			"ClaudeCodeFocus",
			"ClaudeCodeSelectModel",
			"ClaudeCodeAdd",
			"ClaudeCodeSend",
			"ClaudeCodeTreeAdd",
			"ClaudeCodeStatus",
			"ClaudeCodeStart",
			"ClaudeCodeStop",
			"ClaudeCodeOpen",
			"ClaudeCodeClose",
			"ClaudeCodeDiffAccept",
			"ClaudeCodeDiffDeny",
			"ClaudeCodeCloseAllDiffs",
		},
		keys = {
			{ "<leader>o", nil, desc = "AI/Claude Code" },
			{ "<leader>oc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>of", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>or", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>oC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>om", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
			{ "<leader>ob", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>os", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>os",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
			},
			-- Diff management
			{ "<leader>oa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>od", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	})

	use({
		"nickjvandyke/opencode.nvim",
		version = "*", -- Latest stable release
		enabled = false,
		-- enabled = vim.fn.executable("opencode") == 1,
		event = "VeryLazy",
		config = function()
			local opencode = require("opencode")
			math.randomseed(vim.uv.hrtime())
			local random_port = math.random(37000, 38000)
			local server_cmd = string.format("opencode --port %d", random_port)

			---@type opencode.Opts
			vim.g.opencode_opts = {
				server = {
					port = random_port,
					start = function()
						require("opencode.terminal").open(server_cmd, {
							split = "right",
							width = math.floor(vim.o.columns * 0.35),
						})
					end,
					toggle = function()
						require("opencode.terminal").toggle(server_cmd, {
							split = "right",
							width = math.floor(vim.o.columns * 0.35),
						})
					end,
				},
				contexts = {
					["@this-error"] = this_error,
				},
				-- Your configuration, if any; goto definition on the type or field for details
			}

			vim.o.autoread = true -- Required for `opts.events.reload`

			vim.keymap.set({ "n", "x" }, "<leader>oa", function()
				vim.cmd("write")
				opencode.ask("@this: ", { submit = true })
			end, { desc = "Opencode: Ask..." })

			vim.keymap.set({ "n", "x" }, "<leader>oe", function()
				vim.cmd("write")
				opencode.ask("@this-error: ", { submit = true })
			end, { desc = "Opencode: Ask about the errors on this line" })

			vim.keymap.set({ "n", "x" }, "<leader>on", function()
				vim.cmd("write")
				opencode.command("session.new")
				opencode.ask("@this: ", { submit = true })
			end, { desc = "Opencode: Ask in a new session" })

			vim.keymap.set({ "n", "x" }, "<leader>os", function()
				opencode.command("session.select")
			end, { desc = "Opencode: Select session" })

			vim.keymap.set({ "n", "x" }, "<leader>ox", function()
				opencode.select()
			end, { desc = "Opencode: Execute action" })

			vim.keymap.set({ "n", "t" }, "<leader>oo", function()
				opencode.toggle()
			end, { desc = "Opencode: Toggle visibility" })

			vim.keymap.set({ "n", "x" }, "go", function()
				return opencode.operator("@this ")
			end, { desc = "Opencode: Add line range to prompt", expr = true })

			vim.keymap.set("n", "goo", function()
				return opencode.operator("@this ") .. "_"
			end, { desc = "Opencode: Add line to prompt", expr = true })

			vim.keymap.set({ "n", "x" }, "<leader>od", function()
				return opencode.command("prompt.clear")
			end, { desc = "Opencode: Clear prompt", expr = true })

			vim.keymap.set("n", "<A-C-u>", function()
				opencode.command("session.half.page.up")
			end, { desc = "Opencode: Scroll up" })

			vim.keymap.set("n", "<A-C-d>", function()
				opencode.command("session.half.page.down")
			end, { desc = "Opencode: Scroll down" })

			vim.keymap.set("n", "<A-C-t>", function()
				opencode.command("session.first")
			end, { desc = "Opencode: Scroll to top" })

			vim.keymap.set("n", "<A-C-b>", function()
				opencode.command("session.last")
			end, { desc = "Opencode: Scroll to bottom" })
		end,
	})
end

return M
