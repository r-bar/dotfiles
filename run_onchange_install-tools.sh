#!/usr/bin/env bash

set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"
UV_TOOL_BIN_DIR="$PREFIX"
PYLSP_PYTHON_VERSION=3.14
PROFILES="python"

case "$(hostname -s)" in
  venus)
    PROFILES="$PROFILES home"
    ;;
  earth)
    PROFILES="$PROFILES home"
    ;;
  ceres)
    PYLSP_PYTHON_VERSION=3.11
    PROFILES="$PROFILES work"
    ;;
  *)
    ;;
esac

function ubi_install() {
  mise exec ubi -- ubi -v -i "$PREFIX" $@
}

function uv_install() {
  mise exec uv -- uv tool install $@
}

function work_profile() {
  return 0
}

function home_profile() {
  uv_install rembg[cli] --upgrade --python 3.10 --with onnxruntime
  uv_install coconut[jupyter] --upgrade --with ipython
  ubi_install --project roc-lang/nightlies -e roc
}

function python_profile() {
  uv_install ipython --upgrade
  uv_install poetry --upgrade
  uv_install pre-commit --upgrade
  uv_install ruff --upgrade
  uv_install mypy --upgrade
  uv_install ty --upgrade
  uv_install python-lsp-server --upgrade \
    --python $PYLSP_PYTHON_VERSION \
    --with pylsp-rope \
    --with pylsp-mypy \
    --with keyrings.google-artifactregistry-auth \
    --with pylsp-workspace-symbols \
    ;
}

uv_install llm --upgrade --with llm-ollama --with llm-gemini --with llm-openrouter

ubi_install --project git-pkgs/forge
ubi_install --project dandavison/delta

for profile in $PROFILES; do
  echo Installing tools for $profile profile
  "${profile}_profile"
done
