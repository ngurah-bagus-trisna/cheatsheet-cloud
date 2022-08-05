# Install metallb

MetalLB hooks into your Kubernetes cluster, and provides a network load-balancer implementation. In short, it allows you to create Kubernetes services of type LoadBalancer in clusters that don’t run on a cloud provider, and thus cannot simply hook into paid products to provide load balancers.

It has two features that work together to provide this service: address allocation, and external announcement.

### Install on kubernetes cluster

1. Edit configmaps kube proxy

```bash
kubectl edit configmap -n kube-system kube-proxy
```

```yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true # edit from false to true
```

2. Deploy metallb

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.4/config/manifests/metallb-native.yaml
```

### Config metallb

1. Create value.yaml, for add IpAddresPool and L2Advertismen

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.1.210-172.18.1.240 # Sesuaikan dengan ip lease instance
  autoAssign: true
---

apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
```

2. Apply configuration

```bash
kubectl apply -f value.yaml
```

# Next.

Install ingress
