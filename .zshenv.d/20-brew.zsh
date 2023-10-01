HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-/opt/homebrew}

if [ -x $HOMEBREW_PREFIX/bin/brew ]; then
	eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
fi

# add some common "caveat" package variables
if [ -z "$HOMEBREW_NO_EXTRA_ENV" ]; then
  if [ -d $HOMEBREW_PREFIX/opt/coreutils ]; then
    export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"
  fi
  if [ -d $HOMEBREW_PREFIX/opt/libpq ]; then
    export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libpq/lib $LDFLAGS"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libpq/include $CPPFLAGS"
  fi
  if [ -d $HOMEBREW_PREFIX/opt/gnu-tar ]; then
    export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
    export MANPATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnuman:$MANPATH"
  fi
  if [ -d $HOMEBREW_PREFIX/opt/libxml2 ]; then
    export PATH="$HOMEBREW_PREFIX/opt/libxml2/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib $LDFLAGS"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include $CPPFLAGS"
  fi
  if [ -d $HOMEBREW_PREFIX/opt/libyaml ]; then
    export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libyaml/lib $LDFLAGS"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libyaml/include $CPPFLAGS"
  fi
  if [ -d "$HOMEBREW_PREFIX/opt/openssl@1.1" ]; then
    export PATH="$HOMEBREW_PREFIX/opt/openssl@1.1/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_PREFIX/opt/openssl@1.1/lib $LDFLAGS"
    export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openssl@1.1/include $CPPFLAGS"
  fi
fi
