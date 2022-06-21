# Install Monitoring System on Kubernetes

*Prometheus, Kube-state-metrics dan grafana digunakan untuk monitoring cluster kubernetes.*

Mengenai Prometheus ada di [Refrensi](https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/monitoring/Penjelasan-Prometheus.md)

Spesifikasi lab, [Refrensi Buat instance di KVM](https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/create-instance-kvm.md)
| Node  | Spesifikasi |
| ----------- | ----------- |
| k8s-master-1 | 4vcpus, 8 RAM (KVM)|
| k8s-worker-1 | 4vcpus, 8 RAM (KVM)|
| k8s-worker-2 | 4vcpus, 8 RAM (KVM)|

## Install Prometheus

1. Download depedencies

```bash
git clone https://github.com/bibinwilson/kubernetes-prometheus
```

2. Buat namespace & apply clusterRoles

```bash
# Create namespace
kubectl create namespace monitoring

# Create clusterRoles
kubectl create -f clusterRole.yaml
```

3. configmap configuration
Komponen dalam configmap:

| Komponen  | Penjelasan |
| ----------- | ----------- |
| `prometheus.yaml` | This is the main Prometheus configuration which holds all the scrape configs, service discovery details, storage locations, data retention configs, etc)|
| `prometheus.rules` | This file contains all the Prometheus alerting rules|

4. Create configmaps

```bash
kubectl create -f config-map.yaml
```

5. Create prometheus deployment

```bash
kubectl create  -f prometheus-deployment.yaml --namespace=monitoring 
```

6. Create service for prometheus dashboard 

```bash
kubectl create -f prometheus-service.yaml --namespace=monitoring

# Access on port 30000
http://<ip-master>:30000
```

Refrensi : https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/

# Install kube-state-metrics

**Kube State metrics** is a service that talks to the Kubernetes API server to get all the details about all the API objects like deployments, pods, daemonsets, Statefulsets, etc.

1. Clone github repo & deploy
   
```bash
# Clone repo kube-state-metrics
git clone https://github.com/devopscube/kube-state-metrics-configs.git

# apply
kubectl apply -f kube-state-metrics-configs/
```

1. Setup prometheus configMaps. add kube-state-metrics job

```yaml
- job_name: 'kube-state-metrics'
  static_configs:
    - targets: ['kube-state-metrics.kube-system.svc.cluster.local:8080']
```

### Grafana Setup di [Refrensi](https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/monitoring/install-grafana.md)
