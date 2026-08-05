function bwu
  argparse h/help -- $argv
  if test -n "$_flag_help"
    echo "Usage: bwu"
    echo
    echo "Helper function for unlocking the Bitwarden CLI vault and "
    echo "propagating the session."
    echo
    bw --help
  end

  set -f BW_STATUS "$(bw status | jq -r .status)"
  switch "$BW_STATUS"
    case "unauthenticated"
      echo "Logging into BitWarden"
      set -Ux BW_SESSION "$(bw login --raw)"
    case "locked"
      echo "Unlocking Vault"
      set -Ux BW_SESSION "$(bw unlock --raw)"
    case "unlocked"
      echo "Vault is unlocked"
    case '*'
      echo "Unknown Login Status: $BW_STATUS"
      return 1
  end
  bw sync
end
