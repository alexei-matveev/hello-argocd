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

You need to configure
[Ingress](https://argoproj.github.io/argo-cd/operator-manual/ingress/)
separately.  ArgoCD appears to be used with SSL Pass-Through,
according to that page.  SSL Pass-Through is however not an easy task
on k3s wit Traefik 1.7, according to
[Community](https://community.traefik.io/t/tls-passthrough-with-sni-and-k3s/1437).

Anyway, the  Ingress Docs suggests  a Service of type  = LoadBalancer.
For  a starter  you could  check the  ``nodePort`` of  the Service  an
access it directly:

    $ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    $ kubectl get service/argocd-server -n argocd -o yaml

Idetify the ``nodePort`` for "https", usually above 30000, and direct
your browser there:

    https://argocd.localhost:$nodePort

To  get  the  password  see  ``argocd-initial-admin-secret``,  "admin"
appears to be accepted as the user name:

    $ kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r .data.password | base64 -d

Later the manifests were updatet:

    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.1/manifests/install.yaml
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.2/manifests/install.yaml
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.3/manifests/install.yaml
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
    $ kubectl apply -f install.yaml

With v2.0.4 image version has  changed and a ``namespaceSelector`` was
added at one  place. For v2.0.3 only the image  version changed.  With
v2.0.2 the image  version change an a few  NetworkPolicies were added.
For v2.0.1 it was only the image version.

Then you  may consider  adding your first  Application to  the already
available "default" Project  from this Repo with path =  ./app ... See
the [example](./k3s/hello-argocd.yaml) with invalid URL.
