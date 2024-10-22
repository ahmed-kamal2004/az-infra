#!/bin/bash

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

CLUMB=$(curl --location --insecure   --user 'admin':'password'   --url 'http://localhost:8080/crumbIssuer/api/json' --header ".crumb:uniquestringidentifer" | jq -r '.crumb')


sudo service jenkins restart