# puppet-skopeo
[![Tests](https://github.com/deric/puppet-skopeo/actions/workflows/test.yml/badge.svg)](https://github.com/deric/puppet-skopeo/actions/workflows/test.yml)

A module to manage synchronization between Docker/OCI registries.


## Usage

```puppet
include skopeo
```
And configure synchronization rules:
```yaml

skopeo::sync:
  k8s:
    src: registry.k8s.io
    dest: local.reg
    matrix:
      images:
        - kube-apiserver
        - kube-controller-manager
      versions:
        - 1.27.1
        - 1.28.2
```

## Configuration

All Puppet variables are documented in [REFERENCE.md](./docs/REFERENCE.md).
