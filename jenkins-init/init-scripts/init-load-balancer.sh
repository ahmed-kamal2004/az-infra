#!/bin/bash


## Install nginx
sudo apt update
apt install nginx -y


sudo apt install certbot python3-certbot-nginx

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
  upstream backend {
  	server 10.0.1.4:30001 weight=1;
  	server 10.0.1.5:30001 weight=1;
    server 10.0.1.6:30001 weight=1;
  }
  server {
  	server_name localhost;
  	
  	listen 80;
  	
  	location / {
  		proxy_pass http://backend;
  	}
  }
}" > /etc/nginx/nginx.conf


## Restart nginx
service nginx restart

sudo certbot --nginx -d localhost

## Restart nginx
service nginx restart