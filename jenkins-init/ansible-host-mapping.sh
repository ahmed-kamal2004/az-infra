echo "devops@$(terraform output -raw vm_public_ip)" | sudo tee -a /etc/ansible/hosts


ansible all -m ping