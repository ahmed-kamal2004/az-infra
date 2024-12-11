source ./automation-scripts/generate_key.sh

cd terraform 

terraform init

terraform apply -auto-approve

terraform output -raw master_vm_public_ip > ../master_vm_public_ip
# terraform output -raw load_balancer_vm_public_ip > ../load_balancer_vm_public_ip
terraform output -raw slave_vm_public_ip > ../slave_vm_public_ip

cd ..


## Copy the private key
scp -o StrictHostKeyChecking=no -i ./id_rsa ./id_rsa devops@$(cat master_vm_public_ip):/home/devops/

## ssh to master by default
ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat master_vm_public_ip)