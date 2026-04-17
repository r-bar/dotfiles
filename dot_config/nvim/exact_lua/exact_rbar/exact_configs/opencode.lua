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
			end, { desc = "Ask opencode…" })
			vim.keymap.set({ "n", "x" }, "<leader>ox", function()
				opencode.select()
			end, { desc = "Execute opencode action…" })
			vim.keymap.set({ "n", "t" }, "<leader>oo", function()
				opencode.toggle()
			end, { desc = "Toggle opencode" })
			vim.keymap.set({ "n", "x" }, "go", function()
				return opencode.operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "goo", function()
				return opencode.operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })
			vim.keymap.set("n", "<S-C-u>", function()
				opencode.command("session.half.page.up")
			end, { desc = "Scroll opencode up" })
			vim.keymap.set("n", "<S-C-d>", function()
				opencode.command("session.half.page.down")
			end, { desc = "Scroll opencode down" })
		end,
	})
end

return M
