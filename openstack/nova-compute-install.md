# Install Nova on Compute-node

> exec all command on controller-node

```
NOVA_PASS: 90e911b263b95eba484b
NEUTRON_PASS: 0b388ba915de9a052946
RABBIT_PASS: 0b0e0a5c8b36a3c65026

PLACEMENT_PASS: ce4b057ed76829b25b9c
```

1. Install & configure nova

```bash
apt install nova-compute -y

cp /etc/nova/nova.conf /etc/nova/nova.conf.ori
vi /etc/nova/nova.conf
```

```cfg
[DEFAULT]
transport_url = rabbit://openstack:0b0e0a5c8b36a3c65026@controller:5672/

my_ip = {ip_compute}

[api]
auth_strategy = keystone

[keystone_authtoken]
# ...
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
server_listen = 0.0.0.0
server_proxyclient_address = $my_ip
novncproxy_base_url = http://controller:6080/vnc_auto.html

[glance]
api_servers = http://controller:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:5000/v3
username = placement
password = ce4b057ed76829b25b9c

[neutron]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = 0b388ba915de9a052946

service_metadata_proxy = True
metadata_proxy_shared_secret = 653ef24444fadb71b3ae
```

2. Restart nova compute

```bash
systemctl restart nova-compute
systemctl enable nova-compute
systemctl status nova-compute
```

3. Exec on controller

```bash
source admin-openrc
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

openstack compute service list
```
