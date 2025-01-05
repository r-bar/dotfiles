HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-/opt/homebrew}

if [ -x $HOMEBREW_PREFIX/bin/brew ]; then
	eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

  # add some common "caveat" package variables
  if [ -z "$HOMEBREW_NO_EXTRA_ENV" ]; then
    if [ -d $HOMEBREW_PREFIX/opt/coreutils ]; then
      PATH_add "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
      PATH_add MANPATH "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnuman"
    fi

    if [ -d $HOMEBREW_PREFIX/opt/libpq ]; then
      PATH_add "$HOMEBREW_PREFIX/opt/libpq/bin"
      export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libpq/lib $LDFLAGS"
      export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libpq/include $CPPFLAGS"
    fi

    if [ -d $HOMEBREW_PREFIX/opt/gnu-tar ]; then
      PATH_add "$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin"
      PATH_add MANPATH "$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnuman"
    fi

    if [ -d $HOMEBREW_PREFIX/opt/libxml2 ]; then
      PATH_add "$HOMEBREW_PREFIX/opt/libxml2/bin"
      #export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib $LDFLAGS"
      #export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include $CPPFLAGS"
    fi

    if [ -d "$HOMEBREW_PREFIX/opt/openssl@1.1" ]; then
      PATH_add "$HOMEBREW_PREFIX/opt/openssl@1.1/bin"
      #export LDFLAGS="-L$HOMEBREW_PREFIX/opt/openssl@1.1/lib $LDFLAGS"
      #export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openssl@1.1/include $CPPFLAGS"
    fi

    for ldpath in $HOMEBREW_PREFIX/opt/*/lib; do
      #echo adding $ldpath to LDFLAGS
      export LDFLAGS="-L$ldpath $LDFLAGS"
    done

    for cpppath in $HOMEBREW_PREFIX/opt/*/include; do
      #echo adding $cpppath to CPPFLAGS
      export CPPFLAGS="-I$cpppath $CPPFLAGS"
    done
  fi
fi
