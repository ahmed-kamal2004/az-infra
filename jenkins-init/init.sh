#!/bin/bash

# Install Java
apt install default-jre -y


# Install jenkins
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install jenkins -y




## Install nginx
apt install nginx -y


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
  server {
        server_name localhost;
        listen 80;
        location / {
                proxy_pass http://localhost:8080;
        }
  }
}" > /etc/nginx/nginx.conf
service nginx restart

## Outputs
echo $JAVA_HOME