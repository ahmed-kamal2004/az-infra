## To connect with az-cli
az login --service-principal -u <cliendt-id> -p <client-secret> --tenant <tenant-id>

## To start the infrastrcuture
> source apply.sh

## To destroy the infrastrcuture
> source destroy.sh


## Ports Used 
### SonarQube
> 10.0.1.5:9000
### Jenkins Connection with docker engine
> 10.0.1.5:4040
### Kubectl configurations
> 10.0.1.4:7770