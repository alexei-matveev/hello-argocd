#!/usr/bin/env jsonnet

// FWIW, in Jsonet sind Sonderzeichen erlaubt, bei YAML Manifest gibt
// es Bugs [1].
//
// [1] https://github.com/argoproj/argo-cd/issues/6706
{
  apiVersion: 'v1',
  kind: 'Secret',
  type: 'Opaque',
  metadata: {
    namespace: 'hello-argocd',
    name: 'fixme-jsonnet',
  },
  data: {
    unused: std.base64('hello, argocd!'),
  },
}
