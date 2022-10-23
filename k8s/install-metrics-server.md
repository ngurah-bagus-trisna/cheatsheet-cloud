# Install Metrics server k8s

**Metrics Server** collects resource metrics from Kubelets and exposes them in Kubernetes apiserver through Metrics API for use by Horizontal Pod Autoscaler and Vertical Pod Autoscaler. Metrics API can also be accessed by `kubectl top`, making it easier to debug autoscaling pipelines.

## Installation 

1. Get deployment metrics-server

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

2. Edit components.yaml. Add --kubelet-insecure-tls on deployments

```yaml
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
```

3. Install metrics-server

```bash
kubectl apply -f components.yaml
```

> Jika saat `kubectl top pod` menunjukan error `the server is currently unable to handle the request (get nodes.metrics.k8s.io)`,
> di bawah `dnsPolicy` bisa ditambahkan `hostNetwork: true`

4. Makesure metrics-server running on -n kube-system. and test using kubectl top

```bash
kubectl get pod -n kube-system metrics-server-7b857dcf59-s87hx 
# Result
NAME                              READY   STATUS    RESTARTS   AGE
metrics-server-7b857dcf59-s87hx   1/1     Running   0          4m49s

# test using kubectl top
kubectl top node k8s-worker-1
# Result
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-worker-1   31m          0%     566Mi           14%


```
