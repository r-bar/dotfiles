#!/usr/bin/env bash

PREFIX="${PREFIX:-$HOME/.local/bin}"

UV_TOOL_BIN_DIR="$PREFIX"

function ubi_install() {
  mise exec ubi -- ubi -v -i "$PREFIX" $@
}

function uv_install() {
  mise exec uv -- uv tool install $@
}

uv_install httpie --upgrade
uv_install ipython --upgrade
uv_install poetry --upgrade
uv_install pre-commit --upgrade
uv_install ruff --upgrade
uv_install mypy --upgrade
uv_install ty --upgrade
uv_install llm --upgrade --with llm-ollama --with llm-gemini --with llm-openrouter
uv_install coconut[jupyter] --upgrade --with ipython

if [ "$(uname)" != "Darwin" ]; then
  uv_install rembg[cli] --upgrade --python 3.10 --with onnxruntime
fi

if [ "$(hostname -s)" == "ceres" ]; then
  uv_install python-lsp-server --upgrade --python 3.11 --with pylsp-rope --with pylsp-mypy --with keyrings.google-artifactregistry-auth
else
  uv_install python-lsp-server --upgrade --python 3.14 --with pylsp-rope --with pylsp-mypy --with keyrings.google-artifactregistry-auth
fi

ubi_install --project git-pkgs/forge --tag v0.5.1
ubi_install --project dandavison/delta --tag 0.19.2
