source ./automation-scripts/generate_key.sh

cd terraform 

terraform init

terraform apply -auto-approve

terraform output -raw master_vm_public_ip > ../master_vm_public_ip
terraform output -raw slave_vm_public_ip > ../slave_vm_public_ip

cd ..

scp -o StrictHostKeyChecking=no -i ./id_rsa ./id_rsa devops@$(cat master_vm_public_ip):/home/devops/

ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat master_vm_public_ip)