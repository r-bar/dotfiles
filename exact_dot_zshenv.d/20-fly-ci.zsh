function fly_with_env {
  if [ -n "$FLY_TARGET" ]; then
    echo using '$FLY_TARGET' $FLY_TARGET
    fly -t $FLY_TARGET $@
  else
    fly $@
  fi
}

if hash fly 2> /dev/null; then
  alias fly=fly_with_env
fi
