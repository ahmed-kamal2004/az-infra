#!/bin/bash


ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
JENKINS_URL="http://localhost:8080"

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


CLUMB=$(curl --location --insecure   --user 'admin':'password'   --url 'http://localhost:8080/crumbIssuer/api/json' --header ".crumb:uniquestringidentifer" | jq -r '.crumb')


