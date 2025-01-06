function bwu
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
