# Install k3s Ansible on Ubuntu

K3s is a highly available, certified Kubernetes distribution designed for production workloads in unattended, resource-constrained, remote locations or inside IoT appliances.
Execute all node

Spesifikasi Lab
| Node  | Spesifikasi | IP Address
| ----------- | ----------- | --------|
| k3s-master-1 | 1vcpus, 2GB RAM (KVM)  | 192.168.122.21/24 |
| k3s-worker-1 | 1 vcpus, 2GB RAM (KVM)| 192.168.122.22/24  |
| k3s-worker-2 | 1 vcpus, 2GB RAM (KVM)| 192.168.122.23/24  |

1. Konfigurasi /etc/hosts

```bash
sudo vim /etc/hosts
# ------
192.168.122.21  k3s-master-1
192.168.122.22  k3s-worker-1
192.168.122.23  k3s-worker-2
```

2. Configure ssh passwordless di semua nodes

```bash
# Node master-1
ssh-keygen -t rsa
ssh-copy-id ubuntu@k3s-master-1
ssh-copy-id ubuntu@k3s-worker-1
ssh-copy-id ubuntu@k3s-worker-2

# Node worker-1
ssh-keygen -t rsa
ssh-copy-id ubuntu@k3s-master-1
ssh-copy-id ubuntu@k3s-worker-1
ssh-copy-id ubuntu@k3s-worker-2

# Node worker-2
ssh-keygen -t rsa
ssh-copy-id ubuntu@k3s-master-1
ssh-copy-id ubuntu@k3s-worker-1
ssh-copy-id ubuntu@k3s-worker-2

```

3. Install python virtualenviroment

```bash
#install python3 pip
sudo apt install python3-pip

# install virtualenviroment 
sudo pip3 install virtualenv

# create virtualenviroment
virtualenv venv

# Activate virtualenviroment
source venv/bin/activate
```

4. install ansible on virtualenv & download k3s ansible

```bash
# install ansible
pip3 install ansible

# download k3s-ansible
git clone https://github.com/k3s-io/k3s-ansible.git 
```

5. Install k3s

```bash
# masuk ke direktori
cd k3s-ansible

# copy sample config to mycluster
cp -R inventory/sample inventory/my-cluster

# edit inventory/my-cluster/hosts.ini
vim inventory/my-cluster/hosts.ini
# ------
[master]
k3s-master-1

[node]
k3s-worker-1
k3s-worker-2

[k3s_cluster:children]
master
node

# edit inventory/my-cluster/group_vars/all.yml. Ubah dari ansible_user dari debian -> ubuntu
vim inventory/my-cluster/group_vars/all.yml
# ---
k3s_version: v1.22.3+k3s1
ansible_user: ubuntu
systemd_dir: /etc/systemd/system
master_ip: "{{ hostvars[groups['master'][0]]['ansible_host'] | default(groups['master'][0]) }}"
extra_server_args: ""
extra_agent_args: ""

# Running ansible playbook
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini

# Copy accsess kubernetes
scp ubuntu@k3s-master-1:~/.kube/config ~/.kube/config

sudo chmod 644 /etc/rancher/k3s/k3s.yaml

```

6. Test dengan list node

```bash
kubectl get nodes
# ----
NAME           STATUS   ROLES                  AGE   VERSION
k3s-master-1   Ready    control-plane,master   81m   v1.22.3+k3s1
k3s-worker-2   Ready    <none>                 74m   v1.22.3+k3s1
k3s-worker-1   Ready    <none>                 74m   v1.22.3+k3s1
```