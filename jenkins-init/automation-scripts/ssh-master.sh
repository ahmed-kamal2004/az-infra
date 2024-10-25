#!/bin/bash


# sudo rm id_rsa
# terraform output -raw ssh_private_key > id_rsa
# chmod 400 id_rsa
ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat master_vm_public_ip) -y
