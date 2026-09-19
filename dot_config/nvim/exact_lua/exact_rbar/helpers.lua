local M = {}

---@return nil
function M.close_floats()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
end

---@return string
function M.generate_uuid()
	math.randomseed(os.time())
	local random = math.random
	local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
	return string.gsub(template, "x", function()
		local v = random(0, 0xf) -- v is a decimal number 0 to 15
		return string.format("%x", v) --formatted as a hex number
	end)
end

--[[ Generate a uuid and place it at current cursor position --]]
---@return nil
function M.insert_uuid()
	-- Get row and column cursor,
	-- use unpack because it's a tuple.
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local uuid = M.generate_uuid()
	-- Notice the uuid is given as an array parameter, you can pass multiple strings.
	-- Params 2-5 are for start and end of row and columns.
	-- See earlier docs for param clarification or `:help nvim_buf_set_text.
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { uuid })
	vim.api.nvim_win_set_cursor(0, { row, col + uuid:len() })
end

---@param path string
---@return string
local function escape_wildcards(path)
	return path:gsub("([%[%]%?%*])", "\\%1")
end

---@param start_path string
---@param func fun(path: string): string|nil
---@return string|nil
function M.search_ancestors(start_path, func)
	local path = start_path
	while true do
		local result = func(path)
		if result ~= nil then
			return result
		end
		local parent = vim.fs.dirname(path)
		if parent == path then
			return nil
		end
		path = parent
	end
end

--- Returns a function which matches a filepath against the given glob/wildcard patterns.
---@param ... string
---@return fun(startpath: string): string|nil
function M.root_pattern(...)
	local patterns = M.tbl_flatten({ ... })
	return function(startpath)
		-- startpath = M.strip_archive_subpath(startpath)
		for _, pattern in ipairs(patterns) do
			local match = M.search_ancestors(startpath, function(path)
				for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, "/"), true, true)) do
					if vim.uv.fs_stat(p) then
						return path
					end
				end
			end)

			if match ~= nil then
				local real = vim.uv.fs_realpath(match)
				return real or match -- fallback to original if realpath fails
			end
		end
	end
end

---@param ... string
---@return fun(startpath: string): string
function M.root_pattern_or_cwd(...)
	local root_fn = M.root_pattern(...)
	return function(startpath)
		return root_fn(startpath) or vim.uv.cwd()
	end
end

---@param t table
---@return table
function M.tbl_flatten(t)
	return vim.iter(t):flatten(math.huge):totable()
end

return M
