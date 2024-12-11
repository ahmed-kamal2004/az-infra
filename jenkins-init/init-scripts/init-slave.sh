#!/bin/bash

## Install nginx
sudo apt update
apt install nginx -y

## Install certbot
sudo apt install certbot python3-certbot-nginx -y

## Update the domain of mazrof.work.gd
curl https://api.dnsexit.com/dns/ud/?apikey=139YbFblFlIzai7Be936I64FoBJHJs -d host=mazrof.work.gd

## Configuring Nginx
echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;
events {
        worker_connections 768;
}
http {
  upstream frontend {
    server 10.0.1.4:30001 weight=1;
    server 10.0.1.5:30001 weight=1;
  }
  upstream backend {
    server 10.0.1.4:30002 weight=1;
    server 10.0.1.5:30002 weight=1;
  }

  server {
    listen 80;
    server_name mazrof.work.gd;

    location / {
        proxy_pass http://frontend;
    }
  }
}" | sudo tee /etc/nginx/nginx.conf


## Check nginx
sudo nginx -t
## Restart nginx
sudo service nginx restart

## Sleep waiting for ip change esma3
sleep 3m 0s
sudo certbot -n --nginx -d mazrof.work.gd --register-unsafely-without-email --agree-tos


## Restart nginx
sudo service nginx restart