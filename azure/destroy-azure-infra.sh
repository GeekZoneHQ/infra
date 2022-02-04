#!/bin/sh -e

# Reset CELERY_BROKER_URL to an environment variable
cd k8s/
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' celery/celery-secrets.yaml
sed -i 's/"amqp.*"/"$CELERY_BROKER_URL"/' prod/prod-secrets.yaml

# Destroy k8s cluster in Azure
cd ../terraform-azure
terraform init
terraform destroy -auto-approve

# Remove user, cluster and context from kubeconfig
kubectl config delete-user clusterAdmin_GeekZone_GeekZoneCluster
kubectl config delete-cluster GeekZoneCluster
kubectl config delete-context GeekZoneCluster-admin

