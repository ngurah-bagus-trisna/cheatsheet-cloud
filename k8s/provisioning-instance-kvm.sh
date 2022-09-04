#bin/bash

base="/root/images"

instance="/root/instance"

init () {
  echo "Create Dir"
  echo "=========================================" 
  mkdir -p $instance/$1
  echo "Convert image"
  echo "========================================="
  qemu-img convert -f qcow2 -O qcow2 $base/ubuntu-22.04-server-cloudimg-amd64.qcow2 $instance/$1/root-disk.qcow2 
  qemu-img resize $instance/$1/root-disk.qcow2 50G

  echo "create cloud-image"
  echo "========================================="
  echo "
#cloud-config

hostname: $1
users:
  - name: ubuntu
    ssh-authorized-keys:
      - <pubkey> 
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash

  " >> $instance/$1/cloud-init.cfg

  cloud-localds -v $instance/$1/cloud-init.iso $instance/$1/cloud-init.cfg

  echo "$1 done :)"
  echo "========================================="
}

launch () {
  echo "start launch"
  echo ""
  virt-install \
    --name $1 \
    --vcpus 4 \
    --memory 4096 \
    --disk $instance/$1/root-disk.qcow2,format=qcow2 \
    --disk $instance/$1/cloud-init.iso,device=cdrom \
    --os-variant ubuntu22.04 \
    --virt-type kvm \
    --graphics vnc \
    --network network=kubernetes-10.45.45 \
    --import \
    --noautoconsole

  echo "$1 launch done :)"
  echo ""
  echo ""
}


node="nb-prod-master-1 nb-prod-master-2 nb-prod-master-3 nb-prod-worker-1 nb-prod-worker-2 nb-prod-worker-3"

for i in $node 
do
  init $i
  launch $i
done
