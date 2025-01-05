NIX_DAEMON_PROFILE='/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
[ -r "$NIX_DAEMON_PROFILE" ] && . "$NIX_DAEMON_PROFILE"

if [ -d $HOME/.nix-profile/etc/profile.d ]; then
  for profile in $HOME/.nix-profile/etc/profile.d/*.sh; do
    [ -f $profile ] && . $profile
  done
fi
