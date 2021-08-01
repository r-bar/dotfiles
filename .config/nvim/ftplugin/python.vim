setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal textwidth=79
setlocal smarttab
setlocal expandtab
setlocal nosmartindent
setlocal colorcolumn=79

let b:AutoPairs = extend(copy(g:AutoPairs), {
    \"f'":"'", 'f"':'"',
    \"r'":"'", 'r"':'"',
    \"b'":"'", 'b"':'"'
    \})
