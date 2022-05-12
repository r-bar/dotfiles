##################
### Kubernetes ###
##################

function kubectl-reload {
  export KUBECONFIG="$HOME/.kube/config"
  for config in $HOME/.kube/config.d/*.yaml; do
    export KUBECONFIG="${KUBECONFIG}:$config"
  done
  if [ -d "$HOME/.k3d" ]; then
    for config in $HOME/.k3d/kubeconfig-*.yaml; do
      if [ -z "$KUBECONFIG" ]; then
        export KUBECONFIG="$config"
      else
        export KUBECONFIG="${KUBECONFIG}:$config"
      fi
    done
  fi
}

if [ -d "${KREW_ROOT:-$HOME/.krew}" ]; then export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"; fi
kubectl-reload

alias k='kubectl'
alias kc='kubectl --context'
alias kall='kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found'
alias kcd='kubectx'
alias kns='kubens'
