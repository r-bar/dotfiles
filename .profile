# debugging
#echo 'sourcing .profile'

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 002

#if [ "$XDG_SESSION_TYPE" != "x11" ] && [ -n "$BASH_VERSION" ]; then
if [ -n "$BASH_VERSION" ]; then
  #[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load default .bashrc
  [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" # Load default .bashrc
fi
