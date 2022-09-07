# Install Kubernetes on lxd.

1. Create profile for kubernetes

```bash
lxc profile copy default kubernetes

# Edit profile kubernetes
lxc profile edit kubernetes
```

```yaml
config:
  cloud-init.user-data: |
    #cloud-config
    users:
    - name: ubuntu
      ssh-authorized-keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9Px1lylw/ykDE+i1eKPP2dOaT6xqbmMylyawPqH4K1yDGr5Mlf5qsB+PKF4ptgeH4dCu4lQE5wJgsNRI0uyIqfp6TRCP8qFZRDRvqVQV1qVJ72aI/rt8vxbRhed8gXnC+JeQRSGtdcbrYL3jK7KcRq059OKRfWwp5AZDIIYieaVHkvpvrhLYi/1umfX5qfm73lracpHxVn9A9rGGyUZaPNx07S8gr/NuxW53jrHgfLFZSokt6lpY0c2bmNRLnDpkti5pKChnwiTduX9otdRj9CGClwztE57qW7aC8RkAmdAgXMA8dOPbmd+n4kXEks2LO5SQOYILbjOB4cVD525d/9vRo3TRZmFDLq623+Xr1kc18KX6XLwUjFg/ajKq5drYA4IypaWmOF3x5uJFTGD3V1uYZ57ze6ydI1VBClrSpFM/iKEVNEixK3xulosZfbILGFCNROmlVOBeKVTN4OH6PH479zgfnEjdipXJ2b4oQvAqDv/k6QppuLn0+PHYR4L8= ubuntu@lxd-test
      sudo: ['ALL=(ALL) NOPASSWD:ALL']
      groups: sudo
      shell: /bin/bash
  limits.cpu: "2"
  limits.memory: 4GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,nf_nat,overlay,br_netfilter
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw
    sys:rw\nlxc.mount.entry = /dev/kmsg dev/kmsg none defaults,bind,create=file"
  security.nesting: "true"
  security.privileged: "true"
description: Kubernetes LXD profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: default
    size: 20GB
    type: disk
name: kube-prod
used_by: []
```

2. Create lxc virtual-machine for kubernetes using previous profile

```bash
lxc launch ubuntu:20.04 kmaster --profile kubernetes --vm
lxc launch ubuntu:20.04 kworker --profile kubernetes --vm
```

3. Install kuberentes using this tutorial https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/k8s/deploy-Kubernetes-cluster-containerd.md

