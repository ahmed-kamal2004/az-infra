## To get config for kubectl
timeout 4 nc -q 2 10.0.1.4 7770 | tee ff | awk '/EOF/ {exit}'


git clone https://github.com/ahmed-kamal2004/kube-config-SW


kubectl --kubeconfig=ff apply -f ./kube-config-SW/back-config-map.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/db-deploy.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/back-deploy.yaml
kubectl --kubeconfig=ff apply -f ./kube-config-SW/front-deploy.yaml





## To use with kubectl
kubectl --kubeconfig=ff get pods -A

## To expose configurations
while : ; do cat config | nc -l -p 9000 ; done &

## Install docker with our configurations
wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.12.tgz
