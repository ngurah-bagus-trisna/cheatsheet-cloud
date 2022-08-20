# Install placement

Refrensi : https://docs.openstack.org/placement/yoga/install/install-ubuntu.html

```
PLACEMENT_DBPASS: 0f258372f017965c0e5f
PLACEMENT_PASS: ce4b057ed76829b25b9c
```

1. Create database

```bash
mysql
```

```mysql
CREATE DATABASE placement;

GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' \
  IDENTIFIED BY '0f258372f017965c0e5f';
  
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' \
  IDENTIFIED BY '0f258372f017965c0e5f';
```

2. Configure user and endpoints

```bash
. admin-openrc

openstack user create --domain default --password ce4b057ed76829b25b9c placement

openstack role add --project service --user placement admin

openstack service create --name placement \
  --description "Placement API" placement

# add endpoint for placement

openstack endpoint create --region RegionOne \
  placement public http://controller:8778

openstack endpoint create --region RegionOne \
  placement internal http://controller:8778
  
openstack endpoint create --region RegionOne \
  placement admin http://controller:8778

```

3. Install & configure placement

```bash
apt install placement-api

cp  /etc/placement/placement.conf  /etc/placement/placement.conf.ori

vi  /etc/placement/placement.conf
``` 

```cnf
[placement_database]
connection = mysql+pymysql://placement:0f258372f017965c0e5f@controller/placement

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_url = http://controller:5000/v3
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = placement
password = ce4b057ed76829b25b9c
```

4. sync database & restart placement

```bash
su -s /bin/sh -c "placement-manage db sync" placement

service apache2 restart
```

5. Verify

```bash
. admin-openrc

placement-status upgrade check
---

+-------------------------------------------+
| Upgrade Check Results                     |
+-------------------------------------------+
| Check: Missing Root Provider IDs          |
| Result: Success                           |
| Details: None                             |
+-------------------------------------------+
| Check: Incomplete Consumers               |
| Result: Success                           |
| Details: None                             |
+-------------------------------------------+
| Check: Policy File JSON to YAML Migration |
| Result: Success                           |
| Details: None                             |
+-------------------------------------------+


```
