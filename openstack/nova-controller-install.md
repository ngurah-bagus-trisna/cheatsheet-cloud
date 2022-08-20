# Install Nova - Controller

> exec all on root

```bash
NOVA_DBPASS: 6f2265ae74d59956e242
NOVA_PASS: 90e911b263b95eba484b
---
METADATA_SECRET: 653ef24444fadb71b3ae
NEUTRON_DBPASS: a1b11398f565abc54de2
NEUTRON_PASS: 0b388ba915de9a052946
RABBIT_PASS: 0b0e0a5c8b36a3c65026
PLACEMENT_PASS: ce4b057ed76829b25b9c
```

1. Create database

```bash
mysql
```

```mysql
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;

GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
  IDENTIFIED BY '6f2265ae74d59956e242';
  
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
  IDENTIFIED BY '6f2265ae74d59956e242';

GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY '6f2265ae74d59956e242';

GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY '6f2265ae74d59956e242';

GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' \
  IDENTIFIED BY '6f2265ae74d59956e242';

GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' \
  IDENTIFIED BY '6f2265ae74d59956e242';
  
FLUSH PRIVILEGES;
EXIT;
```

2. Configure openstack for nova

```bash
. admin-openrc

openstack user create --domain default --password 90e911b263b95eba484b nova

openstack role add --project service --user nova admin

openstack service create --name nova \
  --description "OpenStack Compute" compute

```

3. Create endpoint for nova

```bash
openstack endpoint create --region RegionOne \
  compute public http://controller:8774/v2.1
  
openstack endpoint create --region RegionOne \
  compute internal http://controller:8774/v2.1
  
openstack endpoint create --region RegionOne \
  compute admin http://controller:8774/v2.1
```

4. Install & configure nova

```bash
apt install nova-api nova-conductor nova-novncproxy nova-scheduler -y

cp /etc/nova/nova.conf /etc/nova/nova.conf.ori

vi /etc/nova/nova.conf
```

```conf
[api_database]
connection = mysql+pymysql://nova:6f2265ae74d59956e242@controller/nova_api

[database]
connection = mysql+pymysql://nova:6f2265ae74d59956e242@controller/nova

[DEFAULT]
transport_url = rabbit://openstack:0b0e0a5c8b36a3c65026@controller:5672/
my_ip = 172.18.25.11 {controller_ip} 

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://controller:5000/
auth_url = http://controller:5000/
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = 90e911b263b95eba484b

[vnc]

enabled = true
server_listen = $my_ip
server_proxyclient_address = $my_ip

[glance]
api_servers = http://controller:9292

[placement]

region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:5000/v3
username = placement
password = ce4b057ed76829b25b9c

[nautron]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = 0b388ba915de9a052946
service_metadata_proxy = true
metadata_proxy_shared_secret = 653ef24444fadb71b3ae

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

```

5. Populate nova database & restart service

```bash
su -s /bin/sh -c "nova-manage api_db sync" nova

su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova

service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

service nova-api enable
service nova-scheduler enable
service nova-conductor enable
service nova-novncproxy enable

service nova-api status
service nova-scheduler status
service nova-conductor status
service nova-novncproxy status
```

6. Verify

```bash
ss -l '( sport = :8774 )'

. admin-openrc
openstack compute service list
```
