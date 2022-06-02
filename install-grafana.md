# Install Grafana

Ini lanjutan project dari [praktek-prometheus](https://github.com/ngurah-bagus-trisna/cheatsheet-cloud/blob/main/praktek-prometheus.md)

Execute on prom-node-1

1. Download grafana

```bash
cd /opt

# Download latest grafana
sudo wget https://dl.grafana.com/enterprise/release/grafana-enterprise-8.5.4.linux-amd64.tar.gz

# Ekstrak grafana
sudo tar -zxvf grafana-enterprise-8.5.4.linux-amd64.tar.gz
``` 

2. Buat service grafana

```bash
# create grafana.service 
vi /etc/systemd/system/grafana.service
# -----
[Unit]
Description=Grafana

[Service]
User=root
ExecStart=/opt/grafana-8.5.4/bin/grafana-server -homepath /opt/grafana-8.5.4/ web

[Install]
WantedBy=default.target

# ----

systemctl daemon-reload
systemctl enable grafana.service
systemctl start grafana.service
systemctl status grafana.service
journalctl -u grafana
```

3. Add prometheus to data source
![Prometheus data source]()