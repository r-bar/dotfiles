if [ -d "$HOME/.modular" ]; then
  export MODULAR_HOME="$HOME/.modular"
fi

if [ -d $HOME/.modular/pkg/packages.modular.com_mojo ]; then
  export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/.modular/pkg/packages.modular.com_mojo/lib:$HOME/.local/lib/mojo:$LD_LIBRARY_PATH"
fi
