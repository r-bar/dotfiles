c = get_config()  # NOQA

c.TerminalInteractiveShell.editing_mode = 'vi'

c.TerminalInteractiveShell.confirm_exit = False

c.InteractiveShellApp.extensions = [
    'autoreload',
]
