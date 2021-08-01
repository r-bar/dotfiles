nix_profiles=( \
  "$HOME/.nix-profile/etc/profile.d/nix.sh" \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
)

for profile in ${nix_profiles[@]}; do
  [ -f $profile ] && . $profile
done
