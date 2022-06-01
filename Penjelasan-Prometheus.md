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