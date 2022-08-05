# Install Kubernetes Cluster

**Kubernetes** adalah platform open source untuk mengelola kumpulan kontainer dalam suatu cluster server

## Install containerd di cluster

> _Exec on all node_

1. Add repository & Instal conainerd

_Refrensi_ : https://docs.docker.com/engine/install/ubuntu/

```bash
sudo apt update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
# add docker GPG

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# setup repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
sudo apt update
sudo apt install containerd.io
```

2. Config containerd

_Refrensi_ : https://devopstales.github.io/kubernetes/k8s-install-containerd/

```bash
# add default config containerd to /etc/containerd. Exec on root
sudo su
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# Configure SystemdCgroup.
nano /erc/containerd/config.toml
```

Change value from false to true

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
      SystemdCgroup = true # default value false
```

3. Configuation networking for runtime

```bash
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
kvm-intel
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Restart containerd
systemctl enable --now containerd
systemctl restart containerd

# try containerd. 
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml
crictl ps
```

## Installing kubeadm, kubelet and kubectl
> *Exeute on all node*

_Refrensi_ : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

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

6. Disable swap

```bash
free -h
swapoff -a
swapoff -a
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab
free -h
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
