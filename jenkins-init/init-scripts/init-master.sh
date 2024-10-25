#!/bin/bash

# Install Java
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y


# Install jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y



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
sudo apt install python3 -y
sudo apt install python3-pip -y

## Outputs
echo $JAVA_HOME



#### Install Jenkins CLI and Plugins

sudo service jenkins restart

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
$CLI -auth devops:9341 install-plugin docker-plugin
$CLI -auth devops:9341 install-plugin github:1.37.0

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







### Wait for apply.sh to copy the ssh id_rsa
sleep 3m 0s

### Kubernetes Commands

## Clone the Main Kubespray Repo
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

sudo pip install -r requirements.txt
sudo pip install ruamel.yaml

cp -rfp inventory/sample inventory/mycluster

declare -a IPS=(10.0.1.4 10.0.1.5)

CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# ansible -i ./inventory/mycluster/hosts.yaml all --private-key ~/id_rsa -m ping

ansible-playbook -i inventory/mycluster/hosts.yaml --become --private-key ~/id_rsa cluster.yml

sudo cat /etc/kubernetes/admin.conf >> ~/.kube/config

