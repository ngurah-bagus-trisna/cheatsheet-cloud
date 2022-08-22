# Install Glance integration with ceph

Refrensi : 
- https://superuser.openstack.org/articles/ceph-as-storage-for-openstack/
- https://docs.openstack.org/glance/yoga/install/install-ubuntu.html

`GLANCE_DBPASS: 1e2c6b4674ec33c33ecd`
`GLANCE_PASS: 3705abf6d254f43aa074`

1. Create database

```bash
mysql
```

```mysql
CREATE DATABASE glance;

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY '1e2c6b4674ec33c33ecd';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY '1e2c6b4674ec33c33ecd';
  
FLUSH PRIVILEGES;
EXIT;
```

2. Create service for glance

```bash
. admin-openrc

openstack user create --domain default --password 3705abf6d254f43aa074 glance

# add glance user to admin
openstack role add --project service --user glance admin

openstack service create --name glance --description "OpenStack Image" image
```

3. Create endpoint for glance

```bash
openstack endpoint create --region RegionOne \
  image public http://controller:9292
  
openstack endpoint create --region RegionOne \
  image internal http://controller:9292
  
openstack endpoint create --region RegionOne \
  image admin http://controller:9292

```

4. Create osd pool for images glance

```bash
ceph osd pool create images 128 

ceph osd pool set images size 2 # set replica to 2
```

5. Install & configure glance

```bash
apt install glance

cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.ori

vi /etc/glance/glance-api.conf

```

```cnf
[database]
connection = mysql+pymysql://glance:1e2c6b4674ec33c33ecd@controller/glance

[keystone_authtoken]

www_authenticate_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = 3705abf6d254f43aa074

[paste_deploy]
flavor = keystone

[glance_store]
stores = glance.store.rbd.Store
default_store = rbd
rbd_store_pool = images
rbd_store_user = images
rbd_store_ceph_conf = /etc/ceph/ceph.conf

```

Restart Glance

```bash
su -s /bin/sh -c "glance-manage db_sync" glance

systemctl restart glance-api 
systemctl status glance-api 
systemctl enable glance-api 

# Verify glance
ss -l '( sport = :9292 )'
```

6. Test Glance

```bash
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

qemu-img convert cirros-0.3.4-x86_64-disk.img cirros-0.3.4-x86_64-disk.raw

glance image-create --name "Cirros 0.3.4" --disk-format raw --container-format bare --visibility public --file cirros-0.3.4-x86_64-disk.raw

openstack image list

sudo rbd ls images
```
