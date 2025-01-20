# ZSH Runtime Config Components

Files ending in `.zsh` will be sourced by `.zshrc` for interactive shell
sessions. Files are sourced in lexical order and are prefixed by their priority
in order to maintain any structural dependencies between components.

There are a few notable priority breakpoints:
* 10: shell plugins declared
* 20-49: general config priority not depending on any shell plugins
* 50: shell plugins are loaded
* 60-79: configuration depending on plugins
* 80: `compinit` and `bashcompinit` are called
* 90: aliases and functions are loaded
