#!/bin/bash

connect(){

 echo "Using server: $(cat $1)";

 ssh -o StrictHostKeyChecking=no -i ./id_rsa devops@$(cat $1);

}

connect $1
