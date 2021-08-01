###########
### k3d ###
###########

if [ -d "$HOME/.k3d" ]; then
  for config in $HOME/.k3d/kubeconfig-*.yaml; do
    if [ -z "$KUBECONFIG" ]; then
      export KUBECONFIG="$config"
    else
      export KUBECONFIG="${KUBECONFIG}:$config"
    fi
  done
fi
