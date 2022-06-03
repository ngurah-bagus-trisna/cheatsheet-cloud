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
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE59zvDSPD6D7UIHGNzkJU2ke2axcSNk+x1VDocpS25Svy1bGDmeBbPYnw1pgEHuKAL4Hk3XKWCgrDwoAwbop+TiuLZtztCa6oz86XCkIN82PVmaNrJ22cY6EobVhVG2OkXka7xDVzAqcjHgnnZCqeVzxVB5XW8YUF988HitS77sMoIO0jHx/a0Yj+zGp9d1MPZsnxSdCjhXGFLWUKrqQyO7af2NUBvxScDdThH/VU0+emOz+kEfEbfOeEEMwP+9Thyysiqb3YhyP3k9DsDZQhev+dHApWcDs5ZbgGkkhAqffbNeP8ELyLlpjb4c6FAfVULL9x4OgRBouHN+vokTc6rMYaTZ5BPJy2ggiOIxwOfYD5myNyTMidunMs7esU6BbZepXME5/jkGlJo5/Ucu/PJCIsPacBG7/wJE5EhiwsUhX4d6geM7ym49XhayhSdmyOEGQM49iWBjos6/NYZnwCQDk+zWmCx/f/5sdFQLZ7MBsS6K+jgZq3eHuigSbmBbU= wait@acer
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
