#!/usr/bin/env bash

uv tool install black --upgrade
uv tool install httpie --upgrade
uv tool install ipython --upgrade
# GAR keyring plugin required for appomni poetry setup
uv tool install poetry --upgrade --with keyring --with keyrings.google-artifactregistry-auth
uv tool install pre-commit --upgrade
uv tool install python-lsp-server --upgrade --with pylsp-rope --with pylsp-mypy --with keyrings.google-artifactregistry-auth
uv tool install ruff --upgrade
uv tool install mypy --upgrade
uv tool install keyring --upgrade --with keyrings.google-artifactregistry-auth
uv tool install ty --upgrade
uv tool install llm --upgrade --with llm-ollama --with llm-gemini
