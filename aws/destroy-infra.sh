#!/bin/sh -e

# Delete resources in k8s
cd aws/k8s
kubectl delete -f namespaces.yaml
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' celery/celery-secrets.yaml

# Destroy k8s cluster in AWS 
cd ../terraform-aws
terraform init
sleep 60
terraform destroy -auto-approve


