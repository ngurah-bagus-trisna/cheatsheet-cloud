# Install Kubernetes Cluster

**Kubernetes** adalah platform open source untuk mengelola kumpulan kontainer dalam suatu cluster server

## Sebelum Install Kubernetes

1. Jalankan script berikut

```bash
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.ipv4.ip_forward     = 1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

## Installing kubeadm, kubelet and kubectl
*Exeute on all node*

1. Update package dan install depedencies

```bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

2.  Download google cloud key

```bash

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gp
```

3. Add the Kubernetes apt repository:

```bash
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

4. Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

5. Configure cgroup docker

```bash
cat > /etc/docker/daemon.json << EOF
{
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
      "max-size": "100m"
      },
      "storage-driver": "overlay2"
}
EOF

# Restart docker

systemctl restart docker.service
```

6. Disable swap

```bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

## Deploy Cluster


1. Deploy cluster dengan kubeadm init

*Exec on master node*

```bash
kubeadm init --upload-certs --pod-network-cidr=10.244.0.0/16

# Jika runtime container eror execute berikut
rm /etc/containerd/config.toml
systemctl restart containerd
kubeadm init --upload-certs --pod-network-cidr=10.244.0.0/16

# Memindahkan cridentials kubernetes
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Add bash complateion 
echo 'source <(kubectl completion bash)' >>~/.bashrc

echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
```

2. Install CNI (Container Network Interface)

```bash
# Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

```

3. Join Worker node

```bash
# Execute on master node

# Create Token
kubeadm token create --print-join-command

# Get Discovery Token CA cert Hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'

# Get API Server Advertise address (Master Node)
# Execute on worker node
kubeadm join [api-server-endpoint] [flags]
```

# Destroy Cluster

```bash
# Exec on worker node
kubectl drain  <node-name> --delete-local-data --ignore-daemonsets

kubectl cordon <node-name>

sudo kubeadm reset
```
