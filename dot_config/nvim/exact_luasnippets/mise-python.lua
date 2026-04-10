local function python_version()
	local out = vim.fn.system("python3 -c 'from sys import version_info as v; print(f\"{v.major}.{v.minor}\")'")
	out = out:gsub("\n", "")
	return out
end

return {
	s({
		trig = "mise-python",
		filetype = "toml",
		desc = "Initialize a mise config with the defaults for python",
	}, {
		t({
			"[tools]",
			'python = "',
		}),
		f(python_version, {}),
		t({
			'"',
			"",
			"[env]",
			'_.python.venv = { path = ".venv", create = true, uv_create_args = ["--seed"] }',
		}),
	}),
}
