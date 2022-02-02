## Geek.Zone's infrastructure

This repo contains all the configuration to create and destroy the infrastructure where Geek.Zone's membership management app runs. This consists of a managed kubernetes cluster running either in the AWS or Azure cloud, provisioned by Terraform. 

### Prerequisites

In an Ubuntu based Linux operating system machine, to provision or destroy the infrastructure, the following tools are required:

* [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [terraform cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* gettext-base 
```sh
sudo apt-get update -y
sudo apt-get install -y gettext
```

### Provision/destroy the infrastructure in the AWS cloud

Run the following script to provision the infrastructure: 
```sh
cd aws
./create-aws-infra.sh
```

Run the following command to destroy the infrastructure:
```sh
cd aws
./destroy-aws-infra.sh
```

### Provision/destroy the infrastructure in the Azure cloud

Run the following script to provision the infrastructure: 
```sh
cd azure
./create-azure-infra.sh
```

Run the following command to destroy the infrastructure:
```sh
cd azure
./destroy-azure-infra.sh
```
