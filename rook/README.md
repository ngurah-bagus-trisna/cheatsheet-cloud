# ROOK - CEPH

Rook is an open source cloud-native storage orchestrator for Kubernetes, providing the platform, framework, and support for a diverse set of storage solutions to natively integrate with cloud-native environments.

Task.
- [ ] Setup enviroment kubernetes v1.15.9
- [ ] Mempelajari konsep Rook-ceph
- [ ] Coba Deploy rook di kubernetes
- [ ] Buat dokumentasi, [Refrensi](https://docs.google.com/document/d/1iohAm71UrHNTCA5z4mQOpQhU05FjHIrGR1jbgjrzhE8/edit)


Refrensi:
- https://computingforgeeks.com/how-to-deploy-rook-ceph-storage-on-kubernetes-cluster/ 
- https://platform9.com/learn/v1.0/tutorials/rook-using-ceph-csi#step-4---storage-class
- https://rook.io/docs/rook/v1.7/pre-reqs.html
- https://www.digitalocean.com/community/tutorials/how-to-set-up-a-ceph-cluster-within-kubernetes-using-rook

## Setup Lab

Cara Akses lab:
> ssh root@lab7.btech.id > ssh ctrl1 > ssh ubuntu@172.18.216.10

| IP           | Instance |
| ------------ | ----------| 
|192.168.0.10 | calico-prod-vrrp |
|192.168.0.11 | calico-prod-master01 |
|192.168.0.12 | calico-prod-master02 |
|192.168.0.13 | calico-prod-master03 |
|192.168.0.14 | calico-prod-worker01 |
|192.168.0.15 | calico-prod-worker02 |
|192.168.0.16 | calico-prod-worker03 |

- [ ] setup haproxy + keepalived [Refrensi](https://go.btech.id/ops/bri/-/issues/311)
- [ ] Deploy cluster kubernetes 


### Prerequisites

Untuk memastikan cluster kubernetes bisa menjalankan `Rook`, bisa cek ke [Refrensi](https://rook.io/docs/rook/v1.7/pre-reqs.html)
These are the minimal setup requirements for the deployment of Rook and Ceph Storage on Kubernetes Cluster.

- A Cluster with minimum of three nodes
- Available raw disk devices (with no partitions or formatted filesystems)
- Or Raw partitions (without formatted filesystem)
- Or Persistent Volumes available from a storage class in block mode 

Add Raw devices/partitions to nodes that will be used by Rook

```bash
# create one volumes on openstack & attach to instance
openstack volume create  --size 40 $volume-cluster-name

# Attach volume to instance
openstack server add volume calico-worker-name $volume-cluster-name --device /dev/vdb
```

### Deploy ROOK on kubernetes

1. Clone `rook` project dari github. 

```bash 
# Clne rock project. Sesuaikan versi rook yang support dengan kubernetes
cd ~/
git clone --single-branch --branch release-1.7 https://github.com/rook/rook.git

# All nodes with available raw devices will be used for the Ceph cluster. As stated earlier, at least three nodes are required
cd rook/deploy/examples/
```

2. Deploy the Rook Operator

```bash
kubectl create -f crds.yaml
```
