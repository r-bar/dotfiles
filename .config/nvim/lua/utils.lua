local M = {}
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

function M.run(command)
  local handle = require('io').popen(command)
  local result = handle:read("*a")
  local exitcode = handle:close()
  return result, exitcode
end


function M.data_home()
  if vim.env.XDG_DATA_HOME then
    return vim.env.XDG_DATA_HOME .. '/nvim'
  else
    return vim.env.HOME .. '/.local/share/nvim'
  end
end


function echom(...)
  vim.cmd(string.format("echom '%s'", string.format(...)))
end
M.echom = echom

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

return M
