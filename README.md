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


```yaml
skopeo::sync:
  repo:
    src: index.docker.io
    dest: local.reg
    dest_type: dir
    by_tag:
      'some_image': 'v2.4'
      'debian': '^12\.\d$'
    args:
      sign-by: AF123DA
      src-authfile: /some/path
```

## Configuration

All Puppet variables are documented in [REFERENCE.md](./docs/REFERENCE.md).
