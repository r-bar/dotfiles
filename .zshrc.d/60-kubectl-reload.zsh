function kubectl-reload {
  export KUBECONFIG="$HOME/.kube/config"
  for config in $HOME/.kube/config.d/*.yaml; do
    export KUBECONFIG="${KUBECONFIG}:$config"
  done
}
