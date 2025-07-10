function ao-switch --description 'Switch the AppOmni gcloud and k8s environment'
  argparse 'g/global' -- $argv
  set -l context $argv[1]

  function _set -V _flag_global
    set -gx $argv[1] $argv[2]
    if set -ql _flag_global && test -n "$TMUX"
      tmux setenv $argv[1] $argv[2]
    end
  end

  switch $context

  case int int-us1
    _set KUBECONFIG /tmp/kubeconfig-appomni-int-us1
    _set PROJECT appomni-sfdc-demo
    _set NAMESPACE dev
    _set AOPOD "int-us1"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials cluster-vpc1
    kubectl config set-context --current --namespace=$NAMESPACE

  case qa-us1
    _set KUBECONFIG /tmp/kubeconfig-appomni-qa-us1
    _set PROJECT appomni-qa-us1
    _set NAMESPACE qa
    _set AOPOD "qa-us1"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-qa-us1 --zone=us-central1
    kubectl config set-context --current --namespace=$NAMESPACE

  case us1 prod prod-us1
    _set KUBECONFIG /tmp/kubeconfig-appomni-prod-us1
    _set PROJECT appomni-prod-us
    _set NAMESPACE prod
    _set AOPOD "prod-us"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-prod-vpc
    kubectl config set-context --current --namespace=$NAMESPACE

  case us2 prod-us2
    _set KUBECONFIG /tmp/kubeconfig-appomni-prod-us2
    _set PROJECT appomni-prod-us2
    _set NAMESPACE "prod"
    _set AOPOD "prod-us2"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-us2 --zone=us-west1
    kubectl config set-context --current --namespace=$NAMESPACE

  case us3 prod-us3
    _set KUBECONFIG /tmp/kubeconfig-appomni-prod-us3
    _set PROJECT appomni-prod-us3
    _set NAMESPACE prod
    _set AOPOD "prod-us3"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-us3 --region us-central1
    kubectl config set-context --current --namespace=$NAMESPACE

  case eu1 prod-eu1
    _set KUBECONFIG /tmp/kubeconfig-appomni-prod-eu1
    _set PROJECT appomni-prod-eu
    _set NAMESPACE "prod"
    _set AOPOD "prod-eu1"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-eu1 --zone=europe-west3
    kubectl config set-context --current --namespace=$NAMESPACE

  case aus1 prod-aus1
    _set KUBECONFIG /tmp/kubeconfig-appomni-prod-aus1
    _set PROJECT appomni-prod-aus1
    _set NAMESPACE "prod"
    _set AOPOD "prod-aus1"
    _set CLOUDSDK_ACTIVE_CONFIG_NAME $PROJECT
    gcloud container clusters get-credentials appomni-aus1 --zone=australia-southeast1
    kubectl config set-context --current --namespace=$NAMESPACE

  case '*'
    echo "Unknown context: $context"
    return 1

  end
  return 0
end
