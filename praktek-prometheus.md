# Lab Test Node Exporter  Using Prometheus & Grafana

Spesifikasi lab, [Refrensi Buat instance di KVM](https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/create-instance-kvm.md)
| Node  | Spesifikasi |
| ----------- | ----------- |
| prom-node-1 | 1 vcpus, 2GB RAM (KVM)|
| prom-node-2 | 1 vcpus, 2GB RAM (KVM)|

## Persiapan
Eksekusi di semua node

1. Masukan hostname node ke /etc/hosts
```bash
# Edit file /etc/hosts
vim /etc/hosts
# ------
192.168.122.10 prom-node-1
192.168.122.11 prom-node-2
# ------
```

2. Ssh keygen, dan copy pubkey ke antar node.
```bash
# Buat ssh key
ssh-keygen -t rsa

# copy ke antar node
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@ubuntu-node-1
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@ubuntu-node-2
```

## Install Node Exporter

Node Exporter is a Prometheus exporter for server level and OS level metrics with configurable metric collectors. It helps us in measuring various server resources such as RAM, disk space, and CPU utilization

Eksekusi di semua node

1. Downoad node exporter dan jalankan node exporter
```bash
# Download node exporter package
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

# Extrack node exporter
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz

# Start node exporter
cd node_exporter-1.3.1.linux-amd64
./node_exporter --help
./node_exporter --version
./node_exporter 

```

2. Akses node exporter di browser
> http://ip-prom-node-1:9100/metrics
> http://ip-prom-node-2:9100/metrics

3. Running node exporter sebagai service 

```bash
vim /etc/systemd/system/node_exporter.service
# --------
[Unit]
Description=Node Exporter

[Service]
User=root
ExecStart=/opt/node_exporter-1.3.1.linux-amd64/node_exporter

[Install]
WantedBy=default.target

# --------

# Reload daemon
systemctl daemon-reload

# Start node exporter service
systemctl enable node_exporter.service
systemctl start node_exporter.service
systemctl status node_exporter.service
journalctl -u node_exporter
```

## Install Prometheus Server

Eksekusi di prom-node-1

1. Download prometheus server package
```bash
# Downlaod prometheus server package
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.36.0/prometheus-2.36.0.linux-amd64.tar.gz

# Extrac prometheus server package
tar xvfz prometheus-2.36.0.linux-amd64.tar.gz
```

2. Configure config.yaml
```bash
cd prometheus-2.36.0.linux-amd64
vim config.yml
# -----
```
config.yml
```yaml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'Prometheus Server'
    static_configs:
    - targets: ['ip-prom-node-1:9090']
  - job_name: 'prom-node'
    static_configs:
    - targets: ['ip-prom-node-1::9100','ip-prom-node-1:9100']
```

3. Start prometheus Server

```bash
./promtool check config config.yml
./prometheus --help
./prometheus --version
./prometheus --config.file=/opt/prometheus-2.36.0.linux-amd64/config.yml
```

4. Akses dari browser
Metrics: http://ip-prom-node-1:9090/metrics
Graph: http://ip-prom-node-1:9090/
Target: http://ip-prom-node-1:9090/targets

5. Running promehtheus using service

```bash
# Create pometheus_service
vi /etc/systemd/system/prometheus_server.service
# ----
[Unit]
Description=Prometheus Server

[Service]
User=root
ExecStart=/opt/prometheus-2.36.0.linux-amd64/prometheus --config.file=/opt/prometheus-2.36.0.linux-amd64/config.yml --web.external-url=http://ip-prom-node-1:9090/

[Install]
WantedBy=default.target
```

6. Start Prometheus Server

```bash
# Restart daemon
systemctl daemon-reload

# Start prometheus server
systemctl enable prometheus_server.service
systemctl start prometheus_server.service
systemctl status prometheus_server.service
journalctl -u prometheus_server
```

# Ekspos Metrics Mysql di Docker

Eksekusi di prom-node-1

## Install Docker

Refrensi: https://docs.docker.com/engine/install/ubuntu/
```bash
# Install depedencies
sudo apt-get update

sudo apt-get install \
ca-certificates \
curl \
gnupg \
lsb-release

# Add docker official GPG key
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Setup repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Setup permission for regular user
sudo groupadd docker

# execute on regular user
sudo usermod -aG docker $USER 
```

## Ekspose metrics exporter docker

1. Setelah docker terinstall, expose metric memakai instruksi dibawah
```json
sudo vi sudo vi /etc/docker/daemon.json
# ------

{
"experimental": true,
"metrics-addr": "192.168.122.10:9323"
}

```

2. Tambahkan job untuk docker metrics ke prometheus

```bash
vi /opt/prometheus-2.10.0.linux-amd64/config.yml
# ----
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus-username'
    static_configs:
    - targets: ['192.168.122.10:9090']
  - job_name: 'node-exporter'
    static_configs:
    - targets: ['192.168.122.10:9100','192.168.122.20:9100']

# add job for docker here
  - job_name: 'mysql-exporter'
    static_configs:
    - targets: ['192.168.122.10:9323']

# -----

# Restart docker & prometheus
systemctl restart docker 
systemctl restart prometheus_server.service
```

3. Setup Docker

```bash
# Create network for mysql
docker network create db_network

# Create and run Mysql inside docker container
docker run -d --name mysql-server \
--publish 3306 \
--network db_network \
--restart unless-stopped \
--env MYSQL_ROOT_PASSWORD=wait \
--volume mysql-server-datadir:/var/lib/mysql \
mysql:8 \
--default-authentication-plugin=mysql_native_password

# Create user for monitoring inside mysql server container
docker exec -it mysql-server -uroot -p 
mysql> CREATE USER 'exporter'@'%' IDENTIFIED BY 'wait' WITH MAX_USER_CONNECTIONS 3;
mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';

# Run mysql exporter 
docker run -d --name mysql-exporter \
--publish 9104 \
--restart always \
--network db_network \
--env DATA_SOURCE_NAME="exporter:wait@(mysql-server:3306)" \
prom/mysqld-exporter:latest \
--collect.info_schema.processlist \
--collect.info_schema.innodb_metrics \
--collect.info_schema.tablestats \
--collect.info_schema.tables \
--collect.info_schema.userstats \
--collect.engine_innodb_status
```

4. Access graph di = http://ip-prom-node-1:9090 Cari expression dibawah
> engine_daemon_container_states_containers

Get uptime value
> (time() - process_start_time_seconds{instance="192.168.122.10:9100",job="mysql-metric"})

Get average ercentage cpu
> 100 - avg (irate(node_cpu_seconds_total{instance="192.168.122.10:9100",job="docker-metric",mode="idle"}[5m])) by (instance) * 100