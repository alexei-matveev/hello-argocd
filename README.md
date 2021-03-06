#### Experiments with ArgoCD in k3s

Assuming you already installed the Token in your local config:

    $ export KUBECONFIG=~/.kube/config
    $ kubectl get nodes
    $ source <(kubectl completion bash)

See installation
[guide](https://argoproj.github.io/argo-cd/getting_started)

    $ kubectl create namespace argocd
    $ kubectl config set-context --current --namespace=argocd
    $ kubectl apply -f k3s/

You may need to re-allpy the custom resource, if CRD is yet unknown at
the first time install.

Then point  your browser  to a  local [URL](https://argocd.localhost).
To    get     the    password    for    the     "admin"    user    see
``argocd-initial-admin-secret``. Output on a line by its own:

    $ echo $(kubectl get secret argocd-initial-admin-secret -n argocd -o json | jq -r .data.password | base64 -d)

Then you  may consider  fixing your first  Application in  the already
available  "default"  Project  by  changing the  invalid  URL  in  the
[example](hello-argocd.yaml) and deploy it:

    $ kubectl apply -f hello-argocd/namespace.yaml
    $ kubectl apply -f hello-argocd.yaml

ArgoCD will not  create namespaces to the  apps, you need to  do it on
your own. BTW, none of these steps  reuired you to download an use the
ArgoCD CLI so far ...

#### Workaround for "yaml: invalid trailing UTF-8 octet"

The   [problem](https://github.com/argoproj/argo-cd/issues/6706)  with
unicode   can   be   indeed   fixed   with   ``kustomize.buildOptions:
--enable_kyaml=false`` as an  additional or likely the  first and only
entry in the ``argocd-cm`` ConfigMap:

    data:
      kustomize.buildOptions: "--enable_kyaml=false"

and after deleting  all the pods the unicode chars  in comments appear
to be accepted. FIXM: how do  you properly restart of reload config in
ArgoCD?

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

Later the manifests were updated:

    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.1/manifests/install.yaml
    ...
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/v2.0.4/manifests/install.yaml
    $ curl -LO https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Patch  the  deployment   for  Ingress  to  work  in   k3s,  this  adds
``--insecure``  to the  command line  making the  ``argocd-server`` to
actually serve content at HTTP port  80 instead of just redirecting to
HTTPS:

    $ patch -i enable-insecure-http-at-port-80.diff install.yaml

Then re-apply:

    $ kubectl apply -f install.yaml

With v2.0.4 image version has  changed and a ``namespaceSelector`` was
added at one  place. For v2.0.3 only the image  version changed.  With
v2.0.2 the image  version change an a few  NetworkPolicies were added.
For v2.0.1 it was only the image version.

FWIW, with  a browser running locally  you can get the  Cluster-IP and
use it to access GUI:

    $ kubectl get svc argocd-server

Alternatively, the Ingress Docs suggests to change the service type to
``LoadBalancer``.   Then  you  could  check the  ``nodePort``  of  the
Service an access it directly:

    $ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    $ kubectl get service/argocd-server -n argocd -o yaml

Idetify the ``nodePort`` for "https", usually above 30000, and direct
your browser there:

    https://argocd.localhost:$nodePort
