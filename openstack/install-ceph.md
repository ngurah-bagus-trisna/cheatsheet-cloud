# Install ceph-deploy

> Prefer running this task on tmux

1. Install chrony untuk time

```bash
sudo apt install chrony

# edit file /etc/chrony/chrony.conf

sudo nano /etc/chrony/chrony.conf

---
pool 3.id.pool.ntp.org iburst

systemctl restart chrony
```

2. Install ceph-deploy

```bash
sudo apt install python3-pip

sudo pip3 install ceph-deploy
```

3. Add user to all node ceph

```bash
sudo useradd -d /home/cephadm -m cephadm -s /bin/bash
sudo passwd cephadm
```

Permit sudo to new user `cephadm`

```bash
echo "cephadm ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephadm
sudo chmod 0440 /etc/sudoers.d/cephadm
```

4. Create ssh-key on master-node/controller node

```bash
ssh-keygen

# Copy to pubkey to another node

cat .ssh/id_rsa.pub >> .ssh/authorized_keys
```

# Deploy Cluster

1. Directory

```bash
mkdir ceph-cluster && cd ceph-cluster
```

2. Deploy ceph on controller

```bash
ceph-deploy new nb-openstack-controller-1
```

if you see that error
`[ceph_deploy][ERROR ] RuntimeError: AttributeError: module 'platform' has no attribute 'linux_distribution'`

fix = `pip3 install git+https://github.com/ceph/ceph-deploy.git`

3. Edit ceph config file

```bash
vi ceph.conf

---
# add public network

public network = {ip-address}/{bits}
```

4. Install ceph to cluster

```bash
ceph-deploy install nb-openstack-controller-1 nb-openstack-compute-1 nb-openstack-compute-2
```

5. deploy mon node 

```bash
ceph-deploy mon create-initiol

# chown all config file to cephadm
sudo chown cephadm:cephadm *
```

6. Deploy admin on controller node

```bash
ceph-deploy admin nb-openstack-controller-1

ceph-deploy mgr create nb-openstack-controller-1
```

7. Add osd to cluster ceph

```bash
ceph-deploy osd create --data {device} {ceph-node}
```

8. verify

```bash
ceph config set mon auth_allow_insecure_global_id_reclaim false
```
