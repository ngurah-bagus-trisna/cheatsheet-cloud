# Monitoring With Prometheus

Refrensi: https://course.adinusa.id/

Prometheus is an open source, metric-based monitoring system. Of course, Prometheus is far from the only one of those out there, so what makes it notable?

Prometheus does one thing and it does it well. It has a simple yet powerful data model and a query language that lets you analyse how your applications and infrastructure are performing. It does no try to solve problems outside of the metrics space, leaving those to other more appropriate tools

## Aksitektur Prometheus

![Arsitektur Prometheus](https://course.adinusa.id/media/markdownx/d1f57852-8cd4-45b3-b344-4370290ab772.png)

**Prometheus Server** adalah komponen utama. Memiliki 3 part yaitu

1. Data Retrival: untuk mengambil data dari endpoint aplikasi
2. Time Series Database: Menyimpan semua matric data dan nantinya data bisa diambil dan di analisis
3. HTTP Server:  Menerima _PromQL_ quary untu menyimpan data dan upload data ke dashboard.

**Pushgateway**: mengizinkan untuk upload metrics dari pekerjaan sekaligus maupun perintah singkat (contoh clean up files, backup, dll)

**Alert Manager**: Memungkinkan untuk mengirim alarm yang akan di triger dari alert yang dibuat di prometheus

**Prometheus Web UI**: Untuk display data di dashboard

## Targets

Prometheus server dapat memonitor segala hal, seperti

- Linux/Windows server
- Application 
- Service 

Hal yang di monitoring prometheus dipanggil **_targets_** 
Contoh hal yang menjadi **_targets_** prometheus seperti:

- linux/windows server: Cpu Status, Usage RAM, Disk Space, dll
- Application: number of request, request duration

Prometheus target mendefinisikan bagaimana prometheus menjabarkan matrics dari berbagai sumber. Jika sumber matrics mengekspos dirinya sendiri, prometheus mengambilnya secara langsung. Jika tidak, Anda membutuhkan sebuat exporters 

## Exporters

![](https://course.adinusa.id/media/markdownx/fd31e5ea-1961-4033-8ebd-15325bd3924a.png)

Exporter adalah software yang mengumpulkan data dari service atau aplikasi yang di ekspos via HTTP di prometheus dari (/metrics endpoint). Beberapa exporter biasanya memiliki target service/aplkasi secara spesifik.

Contoh dari exporter:

- Databases: MySQL, MongoDB & PostgreSQL
- Hardware: Node & Ubiquiti UniFi
- Messaging: RabbitMQ & Kafka
- Storage: Ceph, Gluster & Hadoop
- HTTP: Apache, HAProxy, Nginx, & Varnish

## Metrics

Prometheus mendefinisikan teks metrics yang mudah dimengerti manusia. Metrics disimpan di komponen database prometheus 
![Contoh metrics](https://course.adinusa.id/media/markdownx/b8f99a75-d7e7-4a7c-a371-4e5aeda6d20b.png)

- **#HELP**: Deskripsi dari metrics
- **#Types**: 4 Metrics type

1. **Counter** : Metrics akumulatif yang nilainya hanya dapat meningkat. Hal yang dapatmerubah data counter hanya saat metrics di reset/nilai 0. Contoh Counter : Jumlah permintaan/request, Jumlah kesalahan
![Counter](https://course.adinusa.id/media/markdownx/a46cfab0-9d22-43ff-a793-fefcda70cbff.png)

2. **Gauge** : Gauge metrics adalah snapshot yang memberikan pengukuran yang bisa naik/turun. Contoh, temperature, disk space, memory usage
![Gauge](https://course.adinusa.id/media/markdownx/7199569f-a5eb-4461-9136-08a1d7477559.png)

3. **Histogram** : Jenis metrics ini adalah untuk menentukan frecuency dari value observasi yang disimpan di suatu wadah. Metrics ini berfungsi untuk melacak size dan latency. Contoh Request Durations, Respon Size.
![Histogram](https://course.adinusa.id/media/markdownx/de78729b-2e39-4fed-80f5-64fe1f584e22.png)

4. **Summaries** : Summaries mirib seperti histogram di beberapa hal. Tetapi menyajikan data yang berbeda dan umumnya kurang bermanfaat. Alasan utama untuk menggunakan summaries adalah ketika summaries yang akurat diperlukan, terlepas dari distribusi dan jangkauan peristiwa yang diamati.
![Summaries](https://course.adinusa.id/media/markdownx/0a2c7200-35b4-4be1-bfa8-35207a4aee3d.png)
   


## Service Discovery

Prometheus service discovery adalah cara standar mencari endpoint untuk mendapatkan metrics. Kamu dapat setup scraping mekanisme di prometheus.yaml

Service Discovery bukan hanya tentang menulis daftar server ke prometheus, atau monitoring. Ini adalah masalah yang lebih umum yang akan Anda lihat di seluruh sistem Anda; aplikasi perlu menemukan dependensinya untuk diajak bicara, dan teknisi perangkat keras perlu mengetahui mesin mana yang aman untuk dimatikan dan diperbaiki

Oleh karena itu, Anda seharusnya tidak hanya memiliki daftar mentah mesin dan layanan, tetapi juga konvensi tentang bagaimana mereka diatur dan siklus hidupnya.

- Static: target yang di provide langsung ke prometheus.yaml

```yaml
scrape_configs:
  - job_name: 'prometheus-[username]'
    static_configs:
    - targets: ['10.X.X.10:9090']
```

- File: kamu dapat menyediakan targets di file. File harus berekstensi .json/.yaml

```json
[
  {
    "targets": [ "10.X.X.10:9100", "10.X.X.20:9100" ],
    "labels": {
      "team": "infra",
      "job": "node"
    }
  },
  {
    "targets": [ "10.X.X.10:9090" ],
    "labels": {
      "team": "monitoring",
      "job": "prometheus"
    }
  }
]
```

## Memvisualisasikan data

Data visualisasi adalah salah satu cara simple untuk produksi/melihat informasi. Prometheus mengekspose API, dimana _PromQL_ queries akan memproduksi data mentah untuk virtualisasi

Untuk sekarang, software untuk virtualisasi data terbaik adalah Grafana.

Jenis-jenis data visualisasi:

1. **Expression Browser**: disini kamu dapat langsung menjalankan PromQL langsung dan memvisualisasikan nya secara instant.
![](https://course.adinusa.id/media/markdownx/22505f1d-a68b-4b83-a833-297b6227e582.png)

2. **Console Template**: Console template memberikan akses untuk membuat console menggunakan bahasa Go. Console Template menyajikan data dari prometheus. console template juga adalah cara paling powerfull untuk membuat templates yang akan bisa mudah di source control
![Console Template](https://course.adinusa.id/media/markdownx/712863d0-295e-4af2-9eb8-07f8631836d2.png)

3. **Grafana**: Grafana adalah project open source untuk dashboarding. Ini adalah konsep oleh data source.
![Grafana](https://course.adinusa.id/media/markdownx/98ad1f12-867f-4ab0-be67-07dac4ea3e5b.png)