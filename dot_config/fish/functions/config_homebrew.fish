function config_homebrew

  if test -z "$HOMEBREW_PREFIX"
    set -g HOMEBREW_PREFIX /opt/homebrew
  end

  if test -x $HOMEBREW_PREFIX/bin/brew
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

    if test -z "$HOMEBREW_NO_EXTRA_ENV"

      if test -d "$HOMEBREW_PREFIX/share/man"
        set -gx MANPATH $MANPATH "$HOMEBREW_PREFIX/share/man"
      end

      # GNU packages are not linked by default
      for gnubin in $HOMEBREW_PREFIX/opt/*/libexec/gnubin
        set -gx fish_user_paths $fish_user_paths $gnubin
      end
      for gnuman in $HOMEBREW_PREFIX/opt/*/libexec/gnuman
        set -gx MANPATH $MANPATH $gnuman
      end

      if test -d "$HOMEBREW_PREFIX/opt/libpq"
        set fish_user_paths $fish_user_paths "$HOMEBREW_PREFIX/opt/libpq/bin"
        set -gx LDFLAGS -L$HOMEBREW_PREFIX/opt/libpq/lib $LDFLAGS
        set -gx CPPFLAGS -I$HOMEBREW_PREFIX/opt/libpq/include $CPPFLAGS
      end

      if test -d "$HOMEBREW_PREFIX/opt/libxml2"
        set fish_user_paths $fish_user_paths "$HOMEBREW_PREFIX/opt/libxml2/bin"
        #export LDFLAGS="-L$HOMEBREW_PREFIX/opt/libxml2/lib $LDFLAGS"
        #export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/libxml2/include $CPPFLAGS"
      end

      if test -d "$HOMEBREW_PREFIX/opt/openssl@1.1"
        set fish_user_paths $fish_user_paths "$HOMEBREW_PREFIX/opt/openssl@1.1/bin"
        #export LDFLAGS="-L$HOMEBREW_PREFIX/opt/openssl@1.1/lib $LDFLAGS"
        #export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openssl@1.1/include $CPPFLAGS"
      end

      for ldpath in $HOMEBREW_PREFIX/opt/*/lib
        set -gx LDFLAGS -L$ldpath $LDFLAGS
      end

      for cpppath in $HOMEBREW_PREFIX/opt/*/include
        set -gx CPPFLAGS -I$cpppath $CPPFLAGS
      end

    end
  end
end
