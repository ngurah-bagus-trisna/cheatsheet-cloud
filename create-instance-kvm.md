# Create instance on KVM

KVM (Kernel-based Virtual Machine) is the leading open source virtualisation technology for Linux. It installs natively on all Linux distributions and turns underlying physical servers into hypervisors so that they can host multiple, isolated virtual machines (VMs).

### Install KVM on Ubuntu
1. Install package yang di butuhkan di linux
```bash

sudo apt update
# Install package tersebut
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm

# Check virtualisation
kvm-ok 
# --- output
INFO: /dev/kvm exists
KVM acceleration can be used
```

2. Install cloud-utils
```bash
# Install cloud-utils
sudo apt update && sudo apt install cloud-utils whois -y
```

### Create instance on KVM using Ubuntu 22.04 cloud Image

1. Download image ubuntu 
```bash
# Create direktori kvm and base. Disitu tempat image akan di download
mkdir -p $HOME/kvm/base && cd $HOME/kvm/base

# Download image 
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Ubah dari image dari extensi .img ke .cqow2
mv jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64.qcow2

```
2. Inisilisasikan _Username_, _Password_, _Hostname_ yang nanti akan dibuat 
```bash
# Eksekusi di bash
VM_NAME="ubuntu-server"
```

3. Buat direktori instance dan copy image yang di download ke dalam direktori
```bash
# buat direktori instance
sudo mkdir $HOME/kvm/instance/$VM_NAME

# copy dan convert image ke dalam instance
sudo qemu-img convert -f qcow2 -O qcow2 \
$HOME/kvm/base/jammy-server-cloudimg-amd64.qcow2 \
$HOME/kvm/instance/$VM_NAME/root-disk.qcow2 

```

4. Incerase/perbesar ukuran root-disk instance
```bash
# Misal memperbesar ke 20Gb
sudo qemu-img resize \
$HOME/kvm/instance/$VM_NAME/root-disk.qcow2 20G
```

5. Buat _cloud-init.cfg_ file ini berfungsi untuk menyimpan keterangan instance
```bash
# buat dengan vim
sudo vim cloud-init.cfg
---
#cloud-config

hostname: $hostname
users:
  - name: ubuntu
    ssh-authorized-keys:
      - $PUB_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash

runcmd:
  - echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
  - restart ssh

```

6. Buat .img dari _cloud-init.cfg_ yang tadi telah di buat 
```bash
cloud-localds -v cloud-init.img cloud_init.cfg
```

7. Launch instance
```bash
sudo virt-install \
    --name $VM_NAME \
    --vcpus 1 \ # Menentukan berapa core yang akan dipakai instance
    --memory 2048 \ # Sesuaikan ram
    --disk root-disk.cqow2,format=qcow2 \ # Mount root-disk terlebih dahulu
    --disk cloud-init.img,device=cdrom \ # Mount config file
    --os-type linux \ 
    --os-variant ubuntu22.04 \
    --virt-type kvm \
    --graphics none \
    --network network=default \
    --import \
    --noautoconsole
```

8. Manage Virtual Machine

| Syntax      | Description |
| ----------- | ----------- |
| sudo virsh shutdown _instance-name_ | Shutdown instance         | 
| sudo virsh reboot _instance-name_   | Reboot instance           |
| sudo virsh start _instance-name_    | Start instance            |
| sudo virsh undifine _instance-name_ | Remove instance           |
| sudo virsh list --all               | List instance/Domain      |
| sudo virsh domifaddr _instance-name_| Get ip address instance   |
| sudo virsh nodeinfo                 | Get info node information |
| osinfo-query os                     | Get --os-variant info     |

Refrensi :
- https://medium.com/@art.vasilyev/use-ubuntu-cloud-image-with-kvm-1f28c19f82f8
- https://blog.programster.org/create-ubuntu-20-kvm-guest-from-cloud-image
