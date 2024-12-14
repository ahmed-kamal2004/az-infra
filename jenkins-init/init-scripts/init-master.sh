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

## Install certbot
sudo apt install certbot python3-certbot-nginx -y

## Update the domain of mazrof.work.gd
curl https://api.dnsexit.com/dns/ud/?apikey=139YbFblFlIzai7Be936I64FoBJHJs -d host=mazrof-back.work.gd

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
    server 10.0.1.4:30002 weight=1;
    server 10.0.1.5:30002 weight=1;
  }

  server {
    listen 80;
    server_name mazrof-back.work.gd;

    ## Application Backend
    location /api/ {
     proxy_pass http://backend/;
    }

    ## Jenkins
    location  / {
      proxy_pass http://localhost:8080/;
    }

  }

}" | sudo tee /etc/nginx/nginx.conf

## Check nginx
sudo nginx -t
## Restart nginx
sudo service nginx restart

## Sleep waiting for ip change esma3
sleep 3m 0s
sudo certbot -n --nginx -d mazrof-back.work.gd --register-unsafely-without-email --agree-tos


## Restart nginx
sudo service nginx restart




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
$CLI -auth devops:9341 install-plugin docker-workflow
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


mkdir -p /home/devops/.kube && sudo cp /etc/kubernetes/admin.conf /home/devops/.kube/config && sudo chmod 777 /home/devops/.kube/config


########################## SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
############################################################################################### SETUP ADDONS #########################
#####################################################################

## To expose kubectl configurations (in background)
while : ; do cat /etc/kubernetes/admin.conf | nc -l -p 7770 ; done &


########################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
############################################################################################## Configure Docker in slave script ########
####################################################################
ssh -o StrictHostKeyChecking=no -i /home/devops/id_rsa devops@10.0.1.5 <<EOL

    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    mkdir docker
    cd docker
    sudo apt download docker-ce 
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
 depending on a particular stack or provider.
" | sudo tee ./DEBIAN/control
    tar -cJf control.tar.xz -C DEBIAN .
    ar rcs docker-ce.deb debian-binary control.tar.xz data.tar.xz
    sudo apt-get install ./docker-ce.deb docker-ce-cli containerd docker-buildx-plugin docker-compose-plugin -y

    sudo chmod 777 /var/run/docker.sock
    sudo mkdir /etc/systemd/system/docker.service.d
    echo "[Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4040 -H fd:// --containerd=/run/containerd/containerd.sock" | sudo tee /etc/systemd/system/docker.service.d/override.conf

    sudo groupadd docker
    sudo gpasswd -a jenkins docker
    sudo gpasswd -a devops docker

    sudo systemctl daemon-reload
    sudo systemctl restart docker

    ## Installing Jenkins agent

    sudo docker pull jenkins/agent


    ## Installing SonarQube
    sudo sysctl -w vm.max_map_count=262500
    docker run -d --name sonardb -e POSTGRES_USER=sonar -e POSTGRES_PASSWORD=sonar -e POSTGRES_DB=sonarqube postgres:alpine
    docker run -d --name sonarqube -p 9000:9000 -e SONAR_JDBC_URL=jdbc:postgresql://sonardb:5432/sonarqube -e SONAR_JDBC_USERNAME=sonar -e SONAR_JDBC_PASSWORD=sonar sonarqube
EOL



## Apply jenkins Configurations

export CASC_JENKINS_CONFIG=https://raw.githubusercontent.com/ahmed-kamal2004/utilities/main/config.yaml

sudo service jenkins restart


################################################################################################################
# EEEEEEEE  NNN      N  DDDDDD  
# EE        NN  N    N  DD    DD 
# EEEEEE    N    N   N  DD     DD 
# EE        N     N NN  DD    DD 
# EEEEEEEE  N      NNN  DDDDDD  

#  BBBBBB    YY   YY         AAA     HH   HH   M   M   EEEEEEEE  DDDDDD           KK   KK     AAA     MM    MM    AAA     L
#  B    BB    YY YY        AA   AA   HH   HH   MM MM   EE        DD    DD         KK  KK    AA   AA   M M  M M  AA   AA   L
#  BBBBBBBB     Y          AAAAAAA   HHHHHHH   M M M   EEEEEEEE  DD     DD        KK KK     AAAAAAA   M  MM  M  AAAAAAA   L
#  B    BB      Y          A     A   HH   HH   M   M   EE        DD    DD         KK  KK    A     A   M      M  A     A   L
#  BBBBBB       Y          A     A   HH   HH   M   M   EEEEEEEE  DDDDDD           KK   KK   A     A   M      M  A     A   LLLLLL




## For Phase 3

## To get config for kubectl
timeout 4 nc -q 2 10.0.1.4 7770 | tee ff | awk '/EOF/ {exit}'


git clone https://github.com/ahmed-kamal2004/kube-config-SW


kubectl --kubeconfig=ff apply -f ./kube-config-SW/back-config-map.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/db-deploy.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/back-deploy.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/front-deploy.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/redis-deploy.yaml





## To use with kubectl
kubectl --kubeconfig=ff get pods -A
