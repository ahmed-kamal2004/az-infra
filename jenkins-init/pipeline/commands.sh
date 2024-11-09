## To get config for kubectl
timeout 3 nc -q 2 74.176.61.184 7770 | tee ff | awk '/EOF/ {exit}'

## To use with kubectl
kubectl --kubeconfig=ff get pods -A

## To expose configurations
while : ; do cat config | nc -l -p 9000 ; done &

## Install docker with our configurations
wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.12.tgz
