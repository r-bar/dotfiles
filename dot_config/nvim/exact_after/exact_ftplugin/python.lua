local function reveal_type_selection(sel, last_line)
	local ls = require("luasnip")

	local pad = string.rep(" ", vim.fn.indent(last_line))
	vim.api.nvim_buf_set_lines(0, last_line, last_line, false, { pad })

	for _, snip in ipairs(ls.get_snippets("python")) do
		if snip.trigger == "revealtype" then
			ls.snip_expand(snip, {
				pos = { last_line, #pad },
				expand_params = {
					env_override = {
						TM_SELECTED_TEXT = sel,
						LS_SELECT_RAW = sel,
						LS_SELECT_DEDENT = sel,
					},
				},
			})
			return
		end
	end
	vim.notify("revealtype snippet not found", vim.log.levels.WARN)
end

-- live visual selection: v/. and mode() are valid here
vim.keymap.set("x", "<leader>rt", function()
	local sel = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
	local last_line = math.max(vim.fn.line("v"), vim.fn.line("."))
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	reveal_type_selection(sel, last_line)
end, { buffer = true, desc = "reveal_type(selection) on the next line" })

-- command: visual mode is already gone, so use the '< '> marks instead
vim.api.nvim_buf_create_user_command(0, "RevealType", function(cmd)
	local sel
	if cmd.range == 0 then
		sel = vim.fn.expand("<cword>")
	else
		sel = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() })
	end
	reveal_type_selection(sel, cmd.line2)
end, { range = true, desc = "reveal_type(selection) on the next line" })
