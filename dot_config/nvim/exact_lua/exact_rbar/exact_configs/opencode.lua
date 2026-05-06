---@type ConfigPkg
local M = {}

local function this_error(context)
	local cur_line, cur_col0 = unpack(vim.api.nvim_win_get_cursor(0))
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

function M.packages(use)
	use({
		"nickjvandyke/opencode.nvim",
		version = "*", -- Latest stable release
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
