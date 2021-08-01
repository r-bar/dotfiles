# ZSH Environment Config Components

ZSH source files ending in `.zsh` will be sourced by `.zshenv` for both
interactive and non-interactive usage. By convention source files are prefixed
by the priority and loaded in ascending order.

Unlike `.zshrc.d` there are not as many dependencies between components.
Currently the only breakpoint is at `30-` when aliases are sourced and therefore
could override the behavior of later source files.

If there are no other dependencies to the config file use a priority of 20.
