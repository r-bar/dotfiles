# Uses a local python executable to create a virtualenv for the project
# usage: `use python <python executable path>`
use_python() {
  load_prefix "$1"
  if [[ -x "$1/bin/python" ]]; then
    layout python "$1/bin/python"
  else
    echo "Error: $1/bin/python can't be executed."
    exit
  fi
}

# Uses a specific pyenv version
# usage: `use python <pyenv version>`
use_pyenv() {
  local python_root="$(pyenv root)/versions/$1"
  if ! [[ -x "$python_root/bin/python" ]]; then
    echo "Error: $python_root/bin/python can't be executed."
    exit
  fi
  load_prefix $python_root
}

# Use executables installed via asdf. Not all plugins are supported.
# Requires an associated layout_ function from direnv to work.
# usage: `use asdf <plugin> <version>`
use_asdf() {
  local plugin="$1"
  local version="$2"
  local exe="${3:-$plugin}"
  local asdf_install="${ASDF_DATA_DIR:-$HOME/.asdf}/installs/$plugin/$version"
  load_prefix $asdf_install
  local bin="$asdf_install/bin/$plugin"
  if [[ -x $bin ]]; then
    layout $plugin $bin
  else
    echo "Error: $bin cannot be executed."
    exit 1
  fi
}

use_virtualenv() {
  local venv_path="${1:-`pwd`/venv}"
  if [ ! -d "$venv_path" ]; then
    python -m venv "$venv_path"
  fi
  export VIRTUAL_ENV="$venv_path"
  PATH_add "$venv_path/bin"
}

use_poetry() {
  local venv="$(poetry env info -p)"
  if [ -z "$venv" ]; then
    poetry init -n
    poetry install
    venv="$(poetry env info -p)"
  fi
  use_virtualenv $venv
}
