#!/usr/bin/env sh

MISE_OVERRIDE_CONFIG_FILENAMES="${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}/mise.toml"
mise bootstrap --yes
