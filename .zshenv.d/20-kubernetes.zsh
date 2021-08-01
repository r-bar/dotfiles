##################
### Kubernetes ###
##################

if [ -d "${KREW_ROOT:-$HOME/.krew}" ]; then export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"; fi
if [ -n "$HOME/.kube/config.d" ]; then
  export KUBECONFIG="$HOME/.kube/config"
  for config in $HOME/.kube/config.d/*.yaml; do
    export KUBECONFIG="${KUBECONFIG}:$config"
  done
fi

alias k='kubectl'
alias kc='kubectl --context'
alias kall='kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found'
alias kcd='kubectx'
alias kns='kubens'
