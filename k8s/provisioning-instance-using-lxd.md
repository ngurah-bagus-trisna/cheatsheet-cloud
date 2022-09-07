# Install Kubernetes on lxd.

1. Create profile for kubernetes

```bash
lxc profile copy default kubernetes

# Edit profile kubernetes
lxc profile edit kubernetes
--- # Add line on config
config:
  limits.cpu: "2"
  limits.memory: 2GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,nf_nat,overlay,br_netfilter
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw
    sys:rw\nlxc.mount.entry = /dev/kmsg dev/kmsg none defaults,bind,create=file"
  security.nesting: "true"
  security.privileged: "true"
description: Kubernetes LXD profile
```

2. Create lxc virtual-machine for kubernetes using previous profile

```bash
lxc launch ubuntu:20.04 kmaster --profile kubernetes --vm
lxc launch ubuntu:20.04 kworker --profile kubernetes --vm
```

3. Install kuberentes using this tutorial https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/k8s/deploy-Kubernetes-cluster-containerd.md

