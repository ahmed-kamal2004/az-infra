#!/bin/bash

# Install Java
sudo apt install openjdk-21-jdk -y


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


## Install jq "for trnasfering json to raw data"
sudo apt-get install jq -y


# Install python
sudo apt install python3

## Outputs
echo $JAVA_HOME



#### Install Jenkins CLI and Plugins

ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
JENKINS_URL="http://localhost:8080"
curl -o jenkins-cli.jar $JENKINS_URL/jnlpJars/jenkins-cli.jar
CLI="java -jar jenkins-cli.jar -s $JENKINS_URL"
$CLI -auth admin:$ADMIN_PASSWORD groovy = <<EOF
import jenkins.model.*
import hudson.security.*
def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("devops", "9341")
instance.setSecurityRealm(hudsonRealm)
instance.save()
EOF

## Plugins
$CLI -auth devops:9341 install-plugin dashboard-view
$CLI -auth devops:9341 install-plugin configuration-as-code
$CLI -auth devops:9341 install-plugin cloudbees-folder
$CLI -auth devops:9341 install-plugin antisamy-markup-formatter
$CLI -auth devops:9341 install-plugin build-timeout
$CLI -auth devops:9341 install-plugin credentials-binding
$CLI -auth devops:9341 install-plugin ssh-agent
$CLI -auth devops:9341 install-plugin timestamper
$CLI -auth devops:9341 install-plugin ws-cleanup
$CLI -auth devops:9341 install-plugin ant
$CLI -auth devops:9341 install-plugin workflow-aggregator:2.0
$CLI -auth devops:9341 install-plugin github-branch-source:2.0
$CLI -auth devops:9341 install-plugin pipeline-github-lib:2.0
$CLI -auth devops:9341 install-plugin pipeline-stage-view:2.0
$CLI -auth devops:9341 install-plugin git
$CLI -auth devops:9341 install-plugin ssh-slaves
$CLI -auth devops:9341 install-plugin matrix-auth
$CLI -auth devops:9341 install-plugin pam-auth
$CLI -auth devops:9341 install-plugin ldap
$CLI -auth devops:9341 install-plugin dashboard-view

# CLUMB=$(curl --location --insecure   --user 'admin':'password'   --url 'http://localhost:8080/crumbIssuer/api/json' --header ".crumb:uniquestringidentifer" | jq -r '.crumb')

# Skip setup wizard
$CLI -auth admin:$ADMIN_PASSWORD groovy = <<EOF
import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
EOF

sudo service jenkins restart