# Setup Nextcloud on Rocky Linux

> Refrensi : <https://linux.how2shout.com/how-to-install-nextcloud-on-almalinux-9-rocky-linux-9/>

### Environment Server

- ThinkCentre m910q  (4 core, 4 thread)

### Installasi

> Exec using root

##### Update & install req

```sh
dnf update
dnf install bash-completion wget nano unzip
```

##### Disable SELinux

```sh
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
```

##### Install & Setup Httpd

```sh
dnf install httpd
# enable httpd
systemctl enable --now httpd
# allow for firewalld
firewall-cmd --permanent --add-service={http,https} --zone=public
firewall-cmd --reload
```

> Pastikan web apache bisa diakses

##### Setup PHP 8.1

Setup repository

```sh
dnf install epel-release
dnf -y install http://rpms.remirepo.net/enterprise/remi-release-9.rpm
dnf update
```

Install php

```sh
dnf module reset php
dnf module enable php:remi-8.1
dnf install php php-{cli,mysqlnd,zip,devel,gd,mcrypt,mbstring,curl,xml,pear,bcmath,json,pdo,pecl-apcu,pecl-apcu-devel,ldap}

systemctl enable --now php-fpm.service
sed -i "s/memory_limit = .*/memory_limit = 2GB /" /etc/php.ini
```

##### Setup Nextcloud

Download nextcloud

```
wget https://download.nextcloud.com/server/releases/latest.zip
```

Setup nextcloud

```sh
unzip latest.zip
# move to /var/www/html
mv nextcloud/ /var/www/html/
# Create data for nextcloud
mkdir /data # bisa di luar nextcloud. (Recomendded)
# Permission
chown apache:apache -R /var/www/html/nextcloud
chown apache:apache -R /data
```

##### Setup Virtual Host apache

> Request Cert https using cloudflare dns01
>
> Buat token bisa di <https://dash.cloudflare.com/profile/api-tokens>

```sh
# Install certbot
dnf install certbot python3-certbot python3-certbot-dns-cloudflare

# Create credentials
vi .cloudflare.ini
---
dns_cloudflare_api_token = <random token>

# Request dns
certbot certonly --preferred-challenges=dns --dns-cloudflare \
--server https://acme-v02.api.letsencrypt.org/directory \
--dns-cloudflare-credentials ~/.cloudflare.ini \
--agree-tos -d example.com
```

> Langsung gunakan https

```c
<VirtualHost *:80>
  ServerName example.txt
  ServerAdmin admin@example.com
  RewriteEngine On
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
  ServerName example.com
  ServerAdmin admin@example.com
  DocumentRoot /var/www/html/nextcloud
  <directory /var/www/html/nextcloud>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    SetEnv HOME /var/www/html/nextcloud
    SetEnv HTTP_HOME /var/www/html/nextcloud
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </directory>
  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
  <IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
  </IfModule>
</VirtualHost>
</IfModule>
```

> Pastikan https bisa diakses

```sh
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html(/.*)?"
restorecon -Rv /var/www/html

# Restart apache
systemctl restart httpd
```

##### Setup Mysql

Install mysql

```sh
dnf install mysql mysql-server
systemctl enable --now mysqld
```

Setup mysql database

```sh
mysql_secure_installastion
```

```sh
mysql -u root -p
-> create user 'user'@'localhost' identified by 'Passwor0d';
-> create database nextcloud;
-> grant all privileges on nextcloud.* to 'user'@'localhost';
-> flush privileges;
-> exit
```

### Next setup nextcloud dengan akses webnya. :)
