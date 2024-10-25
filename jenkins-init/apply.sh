source ./automation-scripts/generate_key.sh

cd terraform 

terraform init

terraform apply -auto-approve

terraform output -raw master_vm_public_ip > ../master_vm_public_ip
terraform output -raw slave_vm_public_ip > ../slave_vm_public_ip

cd ..

scp -i ./id_rsa ./id_rsa devops@$(cat master_vm_public_ip):~/
# ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat master_vm_public_ip) <<'EOL'
#     git clone https://github.com/kubernetes-sigs/kubespray.git
#     cd kubespray
#     sudo pip install -r requirements.txt
#     sudo pip install ruamel.yaml
#     cp -rfp inventory/sample inventory/mycluster
#     declare -a IPS=(10.0.1.4 10.0.1.5)
#     CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
#     ansible -i ./inventory/mycluster/hosts.yaml all --private-key ~/id_rsa -m ping
#     ansible-playbook -i inventory/mycluster/hosts.yaml --become --private-key ~/id_rsa cluster.yml
#     sudo cat /etc/kubernetes/admin.conf >> ~/.kube/config
# EOL

ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat master_vm_public_ip)