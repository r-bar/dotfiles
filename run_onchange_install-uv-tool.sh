#!/usr/bin/env bash

uv tool install black --upgrade
uv tool install httpie --upgrade
uv tool install ipython --upgrade
uv tool install poetry --upgrade --with keyring
uv tool install pre-commit --upgrade
uv tool install python-lsp-server --upgrade --with pylsp-rope --with pylsp-mypy
uv tool install ruff --upgrade
uv tool install mypy --upgrade
