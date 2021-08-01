#!/usr/bin/env python3.9
# File generated by pre-commit: https://pre-commit.com
# ID: 138fd403232d2ddd5efb44317e38bf03
import os
import sys

# we try our best, but the shebang of this script is difficult to determine:
# - macos doesn't ship with python3
# - windows executables are almost always `python.exe`
# therefore we continue to support python2 for this small script
if sys.version_info < (3, 3):
    from distutils.spawn import find_executable as which
else:
    from shutil import which

# work around https://github.com/Homebrew/homebrew-core/issues/30445
os.environ.pop('__PYVENV_LAUNCHER__', None)

# start templated
INSTALL_PYTHON = '/usr/bin/python'
ARGS = ['hook-impl', '--config=.pre-commit-config.yaml', '--hook-type=pre-commit']
# end templated
ARGS.extend(('--hook-dir', os.path.realpath(os.path.dirname(__file__))))
ARGS.append('--')
ARGS.extend(sys.argv[1:])

DNE = '`pre-commit` not found.  Did you forget to activate your virtualenv?'
if os.access(INSTALL_PYTHON, os.X_OK):
    CMD = [INSTALL_PYTHON, '-mpre_commit']
elif which('pre-commit'):
    CMD = ['pre-commit']
else:
    raise SystemExit(DNE)

CMD.extend(ARGS)
if sys.platform == 'win32':  # https://bugs.python.org/issue19124
    import subprocess

    if sys.version_info < (3, 7):  # https://bugs.python.org/issue25942
        raise SystemExit(subprocess.Popen(CMD).wait())
    else:
        raise SystemExit(subprocess.call(CMD))
else:
    os.execvp(CMD[0], CMD)
