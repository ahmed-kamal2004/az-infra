#!bin/bash


## Note


sudo rm ./id_rsa
sudo rm ./id_rsa.pub

ssh-keygen -f ./id_rsa -t rsa -b 4096 -q -N ""

chmod 400 ./id_rsa
