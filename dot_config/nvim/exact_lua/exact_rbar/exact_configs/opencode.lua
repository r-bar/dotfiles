---@type ConfigPkg
local M = {}

function M.packages(use)
	use({
		"nickjvandyke/opencode.nvim",
		version = "*", -- Latest stable release
		event = "VeryLazy",
		config = function()
			local opencode = require("opencode")

			---@type opencode.Opts
			-- vim.g.opencode_opts = {
			--   -- Your configuration, if any; goto definition on the type or field for details
			-- }

			vim.o.autoread = true -- Required for `opts.events.reload`

			vim.keymap.set({ "n", "x" }, "<leader>oa", function()
				opencode.ask("@this: ", { submit = true })
			end, { desc = "Opencode: Ask..." })

			vim.keymap.set({ "n", "x" }, "<leader>on", function()
				opencode.command("session.new")
				opencode.ask("@this: ", { submit = true })
			end, { desc = "Opencode: Ask in a new session" })

			vim.keymap.set({ "n", "x" }, "<leader>ox", function()
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

			vim.keymap.set("n", "<S-C-u>", function()
				opencode.command("session.half.page.up")
			end, { desc = "Opencode: Scroll up" })

			vim.keymap.set("n", "<S-C-d>", function()
				opencode.command("session.half.page.down")
			end, { desc = "Opencode: Scroll down" })
		end,
	})
end

return M
