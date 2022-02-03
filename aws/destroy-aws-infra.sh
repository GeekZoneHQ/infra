#!/bin/sh -e

# Delete load-balancer associated to ingress controller
cd k8s/
aws eks --region eu-west-2 update-kubeconfig --name GeekZoneCluster
kubectl delete -f namespaces.yaml
sleep 180
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' celery/celery-secrets.yaml
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' prod/prod-secrets.yaml

# Destroy k8s cluster in AWS 
cd ../terraform-aws
terraform init
sleep 60
terraform destroy -auto-approve


