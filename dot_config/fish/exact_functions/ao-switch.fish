function ao-switch --description 'Switch the AppOmni gcloud and k8s environment'
  set -l context $argv[1]
  switch $context
  case int
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-int-us1;
    set -gx PROJECT appomni-sfdc-demo;
    set -gx NAMESPACE dev;
    set -gx AOPOD "int-us1"
    gcloud config set compute/zone us-central1-c;
    gcloud config set project appomni-sfdc-demo;
    gcloud container clusters get-credentials cluster-vpc1;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case qa1
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-qa-us1;
    set -gx PROJECT appomni-qa-us1;
    set -gx NAMESPACE qa;
    set -gx AOPOD "qa-us1"
    gcloud config set compute/zone us-central1-c;
    gcloud config set project appomni-qa-us1;
    gcloud container clusters get-credentials appomni-qa-us1 --zone=us-central1;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case us1 prod
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-prod-us1;
    set -gx PROJECT appomni-prod-us
    set -gx NAMESPACE prod
    set -gx AOPOD "prod-us"
    gcloud config set compute/zone us-central1-c;
    gcloud config set project appomni-prod-us;
    gcloud container clusters get-credentials appomni-prod-vpc;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case eu1
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-prod-eu1;
    set -gx PROJECT appomni-prod-eu1
    set -gx NAMESPACE "prod"
    set -gx AOPOD "prod-eu1"
    gcloud config set compute/zone europe-west3-a;
    gcloud config set project appomni-prod-eu;
    gcloud container clusters get-credentials appomni-eu1 --zone=europe-west3;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case us2
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-prod-us2;
    set -gx PROJECT appomni-prod-us2
    set -gx NAMESPACE "prod"
    set -gx AOPOD "prod-us2"
    gcloud config set compute/zone us-west1-c;
    gcloud config set project appomni-prod-us2;
    gcloud container clusters get-credentials appomni-us2 --zone=us-west1;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case us3
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-prod-us3;
    set -gx PROJECT appomni-prod-us3
    set -gx NAMESPACE prod
    set -gx AOPOD "prod-us3"
    gcloud config set compute/zone us-central1-f;
    gcloud config set project appomni-prod-us3;
    gcloud container clusters get-credentials appomni-us3 --region us-central1;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case aus1
    set -gx KUBECONFIG /tmp/kubeconfig-appomni-prod-aus1;
    set -gx PROJECT appomni-prod-us3
    set -gx NAMESPACE "prod"
    set -gx AOPOD "prod-aus1"
    gcloud config set compute/zone australia-southeast1-a;
    gcloud config set project appomni-prod-aus1;
    gcloud container clusters get-credentials appomni-aus1 --zone=australia-southeast1;
    kubectl config set-context --current --namespace=$NAMESPACE;
  case '*'
    echo "Unknown context: $context"
    return 1
  end
  return 0
end
