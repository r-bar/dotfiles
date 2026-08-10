-- Configuration for the status bar at the bottom of the window

local CHECK_INTERVAL_MS = 1000

---@type ConfigPkg
local M = {}

local loop = vim.uv or vim.loop

-- Lualine's filename component only tracks buffer state (modified/readonly),
-- so this implements an async indicator for when the file on disk has changed
-- since the buffer last read or wrote it. A baseline mtime is recorded on
-- read/write; each statusline refresh kicks off a non-blocking fs_stat that
-- compares against the baseline and caches the result for the component.
local disk_baseline = {} -- bufnr -> { sec, nsec } mtime at last read/write
local disk_changed = {} -- bufnr -> true when disk mtime differs from baseline
local disk_pending = {} -- bufnr -> true while an fs_stat is in flight
local disk_last_check = {} -- bufnr -> uv.now() of last stat, for throttling

local function refresh_statusline()
	vim.schedule(function()
		pcall(function()
			require("lualine").refresh()
		end)
	end)
end

local function stattable(bufnr)
	if vim.bo[bufnr].buftype ~= "" then
		return nil
	end
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end
	return path
end

-- Snapshots the file's current mtime as the buffer's known-good state
function M.record_disk_baseline(bufnr)
	local path = stattable(bufnr)
	if not path then
		return
	end
	loop.fs_stat(path, function(err, stat)
		if err or not stat then
			return
		end
		disk_baseline[bufnr] = { sec = stat.mtime.sec, nsec = stat.mtime.nsec }
		if disk_changed[bufnr] then
			disk_changed[bufnr] = nil
			refresh_statusline()
		end
	end)
end

local function check_disk(bufnr)
	local path = stattable(bufnr)
	if not path or disk_pending[bufnr] then
		return
	end
	local now = loop.now()
	if disk_last_check[bufnr] and now - disk_last_check[bufnr] < CHECK_INTERVAL_MS then
		return
	end
	disk_last_check[bufnr] = now
	disk_pending[bufnr] = true
	loop.fs_stat(path, function(err, stat)
		disk_pending[bufnr] = nil
		if err or not stat then
			return
		end
		local base = disk_baseline[bufnr]
		if not base then
			-- First sighting (e.g. buffer opened before setup); trust the disk
			disk_baseline[bufnr] = { sec = stat.mtime.sec, nsec = stat.mtime.nsec }
			return
		end
		local changed = stat.mtime.sec ~= base.sec or stat.mtime.nsec ~= base.nsec
		if changed ~= (disk_changed[bufnr] or false) then
			disk_changed[bufnr] = changed or nil
			refresh_statusline()
		end
	end)
end

-- Lualine component: shows an indicator when the file on disk has changed
-- since the buffer last read or wrote it
function M.disk_changed_component()
	local bufnr = vim.api.nvim_get_current_buf()
	check_disk(bufnr)
	return disk_changed[bufnr] and " 🔄" or ""
end

function M.config()
	local group = vim.api.nvim_create_augroup("rbar_statusline_disk", { clear = true })
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "FileChangedShellPost" }, {
		group = group,
		callback = function(ev)
			M.record_disk_baseline(ev.buf)
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		callback = function(ev)
			disk_baseline[ev.buf] = nil
			disk_changed[ev.buf] = nil
			disk_pending[ev.buf] = nil
			disk_last_check[ev.buf] = nil
		end,
	})

	-- Seed baselines for buffers that were loaded before this config ran
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			M.record_disk_baseline(bufnr)
		end
	end
end

function M.packages(use)
	use({
		"nvim-lualine/lualine.nvim",
		opts = {
			options = { theme = "auto" },
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							return str:sub(1, 1)
						end,
					},
				},
				lualine_b = { "diff" },

				lualine_c = {
					{ "filename", path = 1 },
					{ M.disk_changed_component, color = "DiagnosticWarn" },
				},
				lualine_x = {
					"diagnostics",
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "fzf" },
		},
	})
	use("nvim-tree/nvim-web-devicons")
end

return M
