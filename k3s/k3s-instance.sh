#bin/bash

INSTANCE="worker-1 worker-2 master-1"

for i in $INSTANCE
do 
  rm -rf $HOME/kvm/instance/k3s-$i
	mkdir $HOME/kvm/instance/k3s-$i
	qemu-img convert -f qcow2 -O qcow2 \
		$HOME/kvm/base/jammy-server-cloudimg-amd64.qcow2 \
		$HOME/kvm/instance/k3s-$i/root-disk.qcow2
	qemu-img resize \
		$HOME/kvm/instance/k3s-$i/root-disk.qcow2 10G
	
	echo "
#cloud-config
hostname: k3s-$i
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ssh-rsa $PUB-KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
    passwd: $6$Q/b.A2lSrVIvKLxK$Gop.YR9oBV7tevkrA.J2khoR23upn6SMOH0BoYxtlJRXbaEOgT7UWQGqxEL0.mRfgD6tEBVrNi6d4iolsA2yF.
    chpasswd: { expire: False }

runcmd:
  - echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
  - restart ssh
  " >> $HOME/kvm/instance/k3s-$i/cloud-init.cfg

  cloud-localds -v $HOME/kvm/instance/k3s-$i/cloud-init.img $HOME/kvm/instance/k3s-$i/cloud-init.cfg

  virt-install \
    --name k3s-$i \
    --vcpus 1 \
    --memory 2048 \
    --disk $HOME/kvm/instance/k3s-$i/root-disk.qcow2,format=qcow2 \
    --disk $HOME/kvm/instance/k3s-$i/cloud-init.img,device=cdrom \
    --os-variant ubuntujammy \
    --virt-type kvm \
    --network network=default \
    --import \
    --noautoconsole

done
