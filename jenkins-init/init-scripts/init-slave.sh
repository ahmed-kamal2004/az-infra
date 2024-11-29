#!/bin/bash

## Install docker
# sudo apt-get update
# sudo apt-get install ca-certificates curl -y
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# sudo chmod a+r /etc/apt/keyrings/docker.asc

# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update

# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y


## Make docker open to the other vm



## Install nginx
sudo apt update
apt install nginx -y


# sudo apt install certbot python3-certbot-nginx



## Get the Ipaddress
ip_addr=$(curl http://checkip.amazonaws.com)


## Generate Certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/selfsigned.key \
    -out /etc/nginx/selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$ip_addr"

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

  server {
	listen 443 ssl;
    server_name _;

    ssl_certificate /etc/nginx/selfsigned.crt;
    ssl_certificate_key /etc/nginx/selfsigned.key;

    location / {
        proxy_pass http://frontend;
    }
  }

  upstream backend {
  	server 10.0.1.4:30002 weight=1;
  	server 10.0.1.5:30002 weight=1;
  }

  server {
	listen 80;
    server_name _;

    location / {
        proxy_pass http://backend;
    }
  }
  
}" > /etc/nginx/nginx.conf

## Check nginx
sudo nginx -t
## Restart nginx
sudo service nginx restart

# sudo certbot --nginx -d localhost

## Restart nginx
# service nginx restart