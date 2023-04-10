### Setup Redis

Install redis

```sh
dnf install dnf install redis php-phpiredis php-pecl-apcu
```

Konfigurasi config.php nextcloud untuk redis

```php
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
    'host' => 'localhost',
    'port' => 6379,
  ),
```

### Setup Preview Generate

Install priview generate di nextcloud-app
!\[\[Pasted image 20230410102315.png\]\]

Konfigurasi config.php nextcloud

```php
  'enable_previews' => true,
  'preview_libreoffice_path' => '/usr/bin/libreoffice',
  'enabledPreviewProviders' => 
  array (
    0 => 'OC\\Preview\\TXT',
    1 => 'OC\\Preview\\MarkDown',
    2 => 'OC\\Preview\\OpenDocument',
    3 => 'OC\\Preview\\PDF',
    4 => 'OC\\Preview\\MSOffice2003',
    5 => 'OC\\Preview\\MSOfficeDoc',
    6 => 'OC\\Preview\\PDF',
    7 => 'OC\\Preview\\Image',
    8 => 'OC\\Preview\\Photoshop',
    9 => 'OC\\Preview\\TIFF',
    10 => 'OC\\Preview\\SVG',
    11 => 'OC\\Preview\\Font',
    12 => 'OC\\Preview\\MP3',
    13 => 'OC\\Preview\\Movie',
    14 => 'OC\\Preview\\MKV',
    15 => 'OC\\Preview\\MP4',
    16 => 'OC\\Preview\\AVI',
  ),
```

Jalankan perintah berikut di tmux

```sh
sudo -u apache php occ preview:generate-all
```

Buat cronjob untuk generate preview

```sh
crontab -u apache -e
---
0 */12 * * * php /var/www/html/nextcloud/occ preview:pre-generate
```

### Setup cron for cron.php

Buat cronjob untuk `cron.php` (Rekomendasi dari nextcloud)

```sh
crontab -u apache -e
---
*/5  *  *  *  * php /var/www/html/nextcloud/cron.php
```

Ubah settings di basic menjadi cron
!\[\[Pasted image 20230410102151.png\]\]
