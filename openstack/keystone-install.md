# Install keystone (Identity service for openstack)

*Refrensi* = https://docs.openstack.org/keystone/yoga/install/keystone-install-ubuntu.html

The OpenStack Identity service provides a single point of integration for managing authentication, authorization, and a catalog of services.

`KEYSTONE_DBPASS: 5f0b602d1ddb1ac5eeda`

1. Create database 

```bash
mysql
```

```mysql
CREATE DATABASE keystone;

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY '5f0b602d1ddb1ac5eeda';

GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY '5f0b602d1ddb1ac5eeda';
```

2. Install keystone

```bash
apt install keystone
```

3. Configure keysone.conf

```bash

cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.ori
vi /etc/keystone/keystone.conf
---

[database]
connection = mysql+pymysql://keystone:5f0b602d1ddb1ac5eeda@controller/keystone

[token]
#...
provider = fernet
```

```bash
# populate identity service to database
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

4. Initialize Fernet key repositories

```bash
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

```

5. Bootstrap the identity service

```bash
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne

```

6. Configure apache2 server ame & Create admin-openrc

```bash
nano /etc/apache2/apache2.conf 
---
ServerName controller

# Create admin-openrc
vi admin-openrc
---

export OS_USERNAME=admin
export OS_PASSWORD=Skills39
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
```

7. Create service role 

```bash
. admin-openrc

openstack project create --domain default \
  --description "Service Project" service
```
