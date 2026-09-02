return {
	parse({
		trig = "revealtype",
		filetype = "python",
		desc = "Insert a typing.reveal_type statement for type checking",
	}, "from typing import reveal_type; reveal_type(${1:$})"),
	-- s(
	--   {
	--     trig = "revealtype",
	--     filetype = "python",
	--     desc = "Insert a typing.reveal_type statement for type checking",
	--   },
	--   {
	--     t("from typing import reveal_type; reveal_type("),
	--     i(1),
	--     t(")"),
	--   }
	-- ),
}
