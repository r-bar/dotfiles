vim.filetype.add{
  extension = {
    v = 'vlang',
  },
  filename = {
    ['.envrc'] = 'sh',
    ['v.mod'] = 'vlang',
    ['*.tf'] = 'terraform',
    ['inventory.ini'] = 'dosini.ansible',
    ['inventory.yaml'] = 'yaml.ansible',
  },
  pattern = {
    ['.*/playbooks/*.ya\\?ml'] = 'yaml.ansible',
  },
}
