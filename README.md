#### Experiments with ArgoCD in k3s

Assuming you already installed the Token in your local config:

    $ export KUBECONFIG=~/.kube/config
    $ kubectl get nodes
    $ source <(kubectl completion bash)

See installation
[guide](https://argoproj.github.io/argo-cd/getting_started)

    $ kubectl create namespace argocd
    $ kubectl config set-context --current --namespace=argocd
    $ kubectl apply -k k3s/

#### Update from the Upstream

The installation
[guide](https://argoproj.github.io/argo-cd/getting_started/) suggests
the rolling "stable" branch:

    kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

We start with v2.0.0:

    $ cd k3s/
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.0/manifests/install.yaml
    $ kubectl create namespace argocd
    $ kubectl config set-context --current --namespace=argocd
    $ kubectl apply -f install.yaml
