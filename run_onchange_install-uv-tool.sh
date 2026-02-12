#!/usr/bin/env bash

uv tool install black --upgrade
uv tool install httpie --upgrade
uv tool install ipython --upgrade
uv tool install poetry --upgrade
uv tool install pre-commit --upgrade
uv tool install ruff --upgrade
uv tool install mypy --upgrade
uv tool install ty --upgrade
uv tool install llm --upgrade --with llm-ollama --with llm-gemini --with llm-openrouter
uv tool install coconut[jupyter] --upgrade --with ipython

if [ "$(uname)" != "Darwin" ]; then
  uv tool install rembg[cli] --upgrade --python 3.10 --with onnxruntime
fi

if [ "$(hostname -s)" == "ceres" ]; then
  uv tool install python-lsp-server --upgrade --python 3.11 --with pylsp-rope --with pylsp-mypy --with keyrings.google-artifactregistry-auth
else
  uv tool install python-lsp-server --upgrade --python 3.14 --with pylsp-rope --with pylsp-mypy --with keyrings.google-artifactregistry-auth
fi
