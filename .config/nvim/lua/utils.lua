local M = {}
TMUX_TARGET = nil
-- expose Package as a global configuration primitive

function pformat(thing, indent, _level)
  local output_indent = 0
  local indent_str = ' '
  indent = indent or 0
  _level = _level or 0

  while string.len(indent_str) < (indent * _level) do
    indent_str = indent_str .. ' '
    output_indent = output_indent + 1
  end

  local output = ''

  if type(thing) == 'table' then
    if indent > 0 then
      output = output .. '{\n'
    else
      output = output .. '{'
    end
    for k, v in pairs(thing) do
      output = output .. indent_str .. k .. ' = ' .. pformat(v, indent, _level + 1) .. ';'
      if indent > 0 then
        output = output .. '\n'
      end
    end
    if indent > 0 then
      output = output .. indent_str .. '}\n'
    else
      output = output .. indent_str .. '}'
    end
    return output
  elseif type(thing) == 'string' then
    return string.format("'%s'", thing)
  else
    return string.format('%s', thing)
  end
end
M.pformat = pformat

function pprint(thing, indent)
  print(pformat(thing, indent))
end
M.pprint = pprint

function run(command)
  local handle = require('io').popen(command)
  local result = handle:read('*a')
  local exitcode = handle:close()
  return result, exitcode
end
M.run = run


function M.data_home()
  if vim.env.XDG_DATA_HOME then
    return vim.env.XDG_DATA_HOME .. '/nvim'
  else
    return vim.env.HOME .. '/.local/share/nvim'
  end
end


function M.echom(...)
  vim.cmd(string.format("echom '%s'", string.format(...)))
end

-- implementation details sourced from
-- https://github.com/junegunn/vim-plug/issues/912#issuecomment-559973123

function string.strip(s, char)
  char = char or "%s"
  return s:match("^"..char.."*(.-)"..char.."*$")
end

function string.split(s, sep)
  sep = sep or "%s"
  local output = {}
  local pat = "[^"..sep.."]+"
  for part in string.gmatch(s, pat) do
    output[#output + 1] = part
  end
  return output
end

-- [0] 4:nvim-config, current pane 2 - (23:15 24-Oct-22)
function M.tmux_parse_pane(pane_string)
  local session, window, pane = string.match(pane_string, '%[(.+)%] (%d+):.*, current pane (%d+)')
  -- return nil when you request a aliased window (like ~) and the alias does
  -- not resolve
  if session == "" then
    return
  end
  return {
    session = session,
    window = tonumber(window),
    pane = tonumber(pane),
  }
end

function M.tmux_get_pane(pane)
  local cmd = 'tmux display -p'
  -- the cmd is executed in a shell so we have to escape ~
  -- add some extra convenience
  if pane == '~' or pane == 'm' or pane == 'marked' then
    cmd = cmd.." -t '~'"
  elseif pane ~= nil then
    cmd = cmd..' -t '..pane
  end
  print(cmd)
  local pane_string, success = run(cmd)
  if not success then
    error("error communicating with tmux")
  end
  return tmux_parse_pane(pane_string)
end

function M.tmux_marked_pane()
  return tmux_get_pane('~')
end

function M.tmux_set_target(target)
  TMUX_TARGET = target
end

function M.tmux_get_target(target)
  return TMUX_TARGET
end

function M.parse_fugitive_status(statusline)
  return statusline:match('%[Git:?(.*)%((.*)%)%]')
end


return M
