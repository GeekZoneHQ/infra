#!/bin/sh -e

# Reset CELERY_BROKER_URL to an environment variable
cd k8s/
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' celery/celery-secrets.yaml

# Destroy k8s cluster in AWS 
cd ../terraform-azure
terraform init
sleep 60
terraform destroy -auto-approve


