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
./prometheus --config.file=/opt/prometheus-2.10.0.linux-amd64/config.yml
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