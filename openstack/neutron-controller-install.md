# Install Neutron - controller

> Exec on controller

```
NEUTRON_DBPASS: a1b11398f565abc54de2
NEUTRON_PASS: 0b388ba915de9a052946
```

1. Create database

```bash
mysql
```

```mysql
CREATE DATABASE neutron;

GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY 'a1b11398f565abc54de2';
  
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY 'a1b11398f565abc54de2';
```

2. Configure openstack for neutron

```bash
. admin-openrc

openstack user create --domain default --password 0b388ba915de9a052946 neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron \
  --description "OpenStack Networking" network
```

3. Create network endpoint

```bash
openstack endpoint create --region RegionOne \
  network public http://controller:9696
  
openstack endpoint create --region RegionOne \
  network internal http://controller:9696

openstack endpoint create --region RegionOne \
  network admin http://controller:9696

```

4. Install neutron packages

```bash
apt install -y neutron-server neutron-plugin-ml2 openvswitch-common ovn-common ovn-host ovn-central
```

5. configure ovs

```bash
systemctl restart openvswitch-switch
systemctl enable openvswitch-switch
systemctl status openvswitch-switch

ovn-nbctl set-connection ptcp:6641:0.0.0.0 -- \
            set connection . inactivity_probe=60000
ovn-sbctl set-connection ptcp:6642:0.0.0.0 -- \
            set connection . inactivity_probe=60000
            
ovs-vsctl set-manager ptcp:6640:0.0.0.0

systemctl restart ovn-northd
systemctl status ovn-northd
 
systemctl restart ovn-ovsdb-server-sb 
systemctl enable ovn-ovsdb-server-sb 
systemctl status ovn-ovsdb-server-sb

systemctl restart ovn-ovsdb-server-nb 
systemctl enable ovn-ovsdb-server-nb 
systemctl status ovn-ovsdb-server-nb 
```

6. Configure /etc/neutron/neutron.conf 

```bash
cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.ori

vi /etc/neutron/neutron.conf  
```

```cfg
[database]
connection = mysql+pymysql://neutron:a1b11398f565abc54de2@controller/neutron

[DEFAULT]
core_plugin = ml2
service_plugins = ovn-router
allow_overlapping_ips = True
transport_url = rabbit://openstack:0b0e0a5c8b36a3c65026@controller:5672/
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp

[keystone_authtoken]
www_authenticate_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = 0b388ba915de9a052946

[nova]
auth_url = http://controller:5000
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = nova
password = 90e911b263b95eba484b

```

7. configure /etc/neutron/plugins/ml2/ml2_conf.ini

```bash
vi /etc/neutron/plugins/ml2/ml2_conf.ini
```

```cfg
[ml2]
mechanism_drivers = ovn
type_drivers = geneve,flat,vlan
tenant_network_types = geneve
extension_drivers = port_security
overlay_ip_version = 4

[ml2_type_geneve]
vni_ranges = 1:65536
max_header_size = 38

[ml2_type_flat]
flat_networks = provider

[securitygroup]
enable_security_group = true

[ovn]
ovn_nb_connection = tcp:172.18.25.11:6641
ovn_sb_connection = tcp:172.18.25.11:6642
ovn_l3_scheduler = leastloaded
ovn_metadata_enabled = true
enable_distributed_floating_ip = false
```

8. Populate neutron database

```bash
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

9. Configure tunnel network ovs

```bash
export my_ip=172.18.25.11
ovs-vsctl set open . external-ids:ovn-remote="tcp:172.18.25.11:6642"
ovs-vsctl set open . external_ids:ovn-nb="tcp:172.18.25.11:6641"
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$my_ip

ovs-vsctl --may-exist add-br br-provider -- set bridge br-provider protocols=OpenFlow13
ovs-vsctl set open . external-ids:ovn-bridge-mappings=provider:br-provider
ovs-vsctl --may-exist add-port br-provider enp2s0
ovs-vsctl set open . external-ids:ovn-cms-options=enable-chassis-as-gw

systemctl restart neutron-server
systemctl enable neutron-server
systemctl status neutron-server
```

10. Verify

```bash
ss -l '( sport = :9696 )'

openstack network agent list
---

+--------------------------------------+------------------------------+------------+-------------------+-------+-------+----------------+
| ID                                   | Agent Type                   | Host       | Availability Zone | Alive | State | Binary         |
+--------------------------------------+------------------------------+------------+-------------------+-------+-------+----------------+
| 07c2e9a1-74ba-4465-a85d-32926817c5ba | OVN Controller Gateway agent | controller |                   | :-)   | UP    | ovn-controller |
+--------------------------------------+------------------------------+------------+-------------------+-------+-------+----------------+

```


