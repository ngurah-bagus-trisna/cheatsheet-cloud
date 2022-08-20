# pre·req·ui·site Install Openstack

> exec all on root

1. Create password for service openstack

ROOT_DBPASS: 5aca19f716b8c00aef6c 
ADMIN_PASS: c453a531afddd1eee49d
CINDER_DBPASS: cf0dc56cc3b1ad652b90
CINDER_PASS: e559094ea05d01a7bb7c
DASH_DBPASS: e1bfd4f9f76357e59f18
GLANCE_DBPASS: 1e2c6b4674ec33c33ecd
GLANCE_PASS: 3705abf6d254f43aa074
KEYSTONE_DBPASS: 5f0b602d1ddb1ac5eeda
PLACEMENT_DBPASS: 0f258372f017965c0e5f
PLACEMENT_PASS: ce4b057ed76829b25b9c
NOVA_DBPASS: 6f2265ae74d59956e242
NOVA_PASS: 90e911b263b95eba484b
METADATA_SECRET: 653ef24444fadb71b3ae
NEUTRON_DBPASS: a1b11398f565abc54de2
NEUTRON_PASS: 0b388ba915de9a052946
HEAT_ADMIN_PASS: adf56fc5e41619820014
HEAT_PASS: 23626e00ca129d860437
HEAT_DBPASS: 54124d5b3e44069ea63a
SWIFT_PASS: 2a8a8c127ad1dd4932a9
SWIFT_SUFFIX: bd7ab60636c78ed9ea9e
SWIFT_PREFIX: 0e540eaceadc91f6c8d6
RABBIT_PASS: 0b0e0a5c8b36a3c65026


2. Add repository Yoga openstack

```bash
add-apt-repository cloud-archive:yoga

sudo apt install python3-openstackclient
```

3. Install sql database

```bash
apt install mariadb-server python3-pymysql

# Configure database for openstack

nano /etc/mysql/mariadb.conf.d/99-openstack.cnf

```

```cnf
[mysqld]
bind-address = {controller_ip}

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

```

```bash
# Restart service mysql

service mysql restart

mysql_secure_installation
``` 

4. Install rabbtmq-server

```bash
apt install rabbitmq-server

# add user openstack

rabbitmqctl add_user openstack 0b0e0a5c8b36a3c65026

rabbitmqctl set_permissions openstack ".*" ".*" ".*"

```

5. Install memcached

```bash
apt install memcached python3-memcache

# edit /etc/memcached.conf. replace line -l 127.0.01 to bellow

-l {controller_ip}

# Makesure memecached-server on

ss -l '( sport = :11211 )'
```

6. Install etcd

```bash
apt install etcd

# Edit config etcd

nano /etc/default/etcd
```

```cnf
ETCD_NAME="controller"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="controller=http://172.18.25.11:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://172.18.25.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://172.18.25.11:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://172.18.25.11:2379"
```
