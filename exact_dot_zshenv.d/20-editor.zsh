if hash nvim 2> /dev/null; then export EDITOR=nvim; else export EDITOR=vi; fi

# if set a variable to determine if this is a development machine
HOSTNAME="$(hostname 2> /dev/null || cat /etc/hostname 2> /dev/null)"
case $HOSTNAME in
  earth)
    export VIM_ENV="development"
    ;;
  venus)
    export VIM_ENV="development"
    ;;
  MARS)
    export VIM_ENV="development"
    ;;
  Ryans-MBP)
    export VIM_ENV="development"
    ;;
  *)
esac
