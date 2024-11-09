#!/bin/bash


########################## SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
############################################################################################### SETUP JENKINS #########################
#####################################################################


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






########################## SETUP KUBERNETES #########################
############################################################################################### SETUP KUBERNETES #########################
############################################################################################### SETUP KUBERNETES #########################
############################################################################################### SETUP KUBERNETES #########################
############################################################################################### SETUP KUBERNETES #########################
############################################################################################### SETUP KUBERNETES #########################
#####################################################################

# Install python
sudo apt install python3 -y
sudo apt install python3-pip -y

### Wait for apply.sh to copy the ssh id_rsa
sleep 1m 0s

### Kubernetes Commands

## Clone the Main Kubespray Repo
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

sudo pip install -r requirements.txt
sudo pip install ruamel.yaml

cp -rfp inventory/sample inventory/mycluster

# declare -a IPS=(10.0.1.4 10.0.1.5)

echo "all:
  hosts:
    node1:
      ansible_host: 10.0.1.4
      ip: 10.0.1.4
      access_ip: 10.0.1.4
      ansible_user: devops
    node2:
      ansible_host: 10.0.1.5
      ip: 10.0.1.5
      access_ip: 10.0.1.5
      ansible_user: devops
  children:
    kube_control_plane:
      hosts:
        node1:
        node2:
    kube_node:
      hosts:
        node1:
        node2:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}" | sudo tee ./inventory/mycluster/hosts.yaml


# ansible -i ./inventory/mycluster/hosts.yaml all --private-key ~/id_rsa -m ping

ansible-playbook -i inventory/mycluster/hosts.yaml --become --private-key /home/devops/id_rsa cluster.yml

sudo cat /etc/kubernetes/admin.conf >> ~/.kube/config



########################## SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
#####################################################################

## To expose kubectl configurations (in background)
while : ; do cat ~/.kube/config | nc -l -p 7770 ; done &


########################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
####################################################################
ssh -o StrictHostKeyChecking=no -i /home/devops/id_rsa devops@10.0.1.5 <<EOL
    mkdir docker-XXX
    cd docker-XXX
    apt download docker-ce 
    ar xf docker-ce_*.deb
    mkdir DEBIAN
    tar xf control.tar.xz -C DEBIAN
    echo "Package: docker-ce
Version: 5:27.3.1-1~ubuntu.24.04~noble
Architecture: amd64
Maintainer: Docker <support@docker.com>
Installed-Size: 108278
Depends: containerd (>= 1.6.24), docker-ce-cli, iptables, libseccomp2 (>= 2.3.0), libc6 (>= 2.34), libsystemd0
Recommends: apparmor, ca-certificates, docker-ce-rootless-extras, git, libltdl7, pigz, procps, xz-utils
Suggests: aufs-tools, cgroupfs-mount | cgroup-lite
Conflicts: docker (<< 1.5~), docker-engine, docker.io
Replaces: docker-engine
Section: admin
Priority: optional
Homepage: https://www.docker.com
Description: Docker: the open-source application container engine
Docker is a product for you to build, ship and run any application as a
lightweight container
.
Docker containers are both hardware-agnostic and platform-agnostic. This means
they can run anywhere, from your laptop to the largest cloud compute instance and
everything in between - and they don't require you to use a particular
language, framework or packaging system. That makes them great building blocks
for deploying and scaling web apps, databases, and backend services without
depending on a particular stack or provider." | tee ./DEBIAN/control
    tar -cJf control.tar.xz -C DEBIAN .
    ar rcs docker-ce.deb debian-binary control.tar.xz data.tar.xz
    sudo apt-get install ./docker-ce.deb docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && sudo apt-get install docker-ce docker-ce-cli containerd docker-buildx-plugin docker-compose-plugin
EOLssh -o StrictHostKeyChecking=no -i /home/devops/id_rsa devops@10.0.1.5 <<EOL
    mkdir docker-XXX
    cd docker-XXX
    apt download docker-ce 
    ar xf docker-ce_*.deb
    mkdir DEBIAN
    tar xf control.tar.xz -C DEBIAN
    echo "Package: docker-ce
Version: 5:27.3.1-1~ubuntu.24.04~noble
Architecture: amd64
Maintainer: Docker <support@docker.com>
Installed-Size: 108278
Depends: containerd (>= 1.6.24), docker-ce-cli, iptables, libseccomp2 (>= 2.3.0), libc6 (>= 2.34), libsystemd0
Recommends: apparmor, ca-certificates, docker-ce-rootless-extras, git, libltdl7, pigz, procps, xz-utils
Suggests: aufs-tools, cgroupfs-mount | cgroup-lite
Conflicts: docker (<< 1.5~), docker-engine, docker.io
Replaces: docker-engine
Section: admin
Priority: optional
Homepage: https://www.docker.com
Description: Docker: the open-source application container engine
Docker is a product for you to build, ship and run any application as a
lightweight container
.
Docker containers are both hardware-agnostic and platform-agnostic. This means
they can run anywhere, from your laptop to the largest cloud compute instance and
everything in between - and they don't require you to use a particular
language, framework or packaging system. That makes them great building blocks
for deploying and scaling web apps, databases, and backend services without
depending on a particular stack or provider." | tee ./DEBIAN/control
    tar -cJf control.tar.xz -C DEBIAN .
    ar rcs docker-ce.deb debian-binary control.tar.xz data.tar.xz
    sudo apt-get install ./docker-ce.deb docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && sudo apt-get install docker-ce docker-ce-cli containerd docker-buildx-plugin docker-compose-plugin
    sudo systemctl daemon-reload
    sudo systemctl restart docker
EOL




################################################################################################################
# EEEEEEEE  NNN      N  DDDDDD  
# EE        NN  N    N  DD    DD 
# EEEEEE    N    N   N  DD     DD 
# EE        N     N NN  DD    DD 
# EEEEEEEE  N      NNN  DDDDDD  