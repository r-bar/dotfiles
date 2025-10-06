local M = {}

function M.close_floats()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
end

function M.generate_uuid()
  math.randomseed(os.time())
  local random = math.random
  local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  return string.gsub(template, "x", function()
    local v = random(0, 0xf)      -- v is a decimal number 0 to 15
    return string.format("%x", v) --formatted as a hex number
  end)
end

--[[ Generate a uuid and place it at current cursor position --]]
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

return M
