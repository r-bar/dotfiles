local function date()
	local out = vim.fn.system("date -Isec")
	local trimmed = string.gsub(out, "\n", "")
	return trimmed
end

return {
	s({
		trig = "uv-script",
		filetype = "all",
		desc = "Create a self managing uv / python script with dependencies",
	}, {
		t({
			"#!/usr/bin/env -S uv run --script",
			"# /// script",
			'# requires-python = ">=3.14"',
			"# dependencies = [",
			'#   "anyio",',
			'#   "httpx",',
			'#   "rich",',
			"# ]",
			"#",
			"# [tool.uv]",
			'# exclude-newer = "',
		}),
		f(date, {}),
		t({
			'"',
			"# ///",
		}),
	}),
}
