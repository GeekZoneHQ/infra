#!/bin/sh -e

# Launch k8s cluster in Azure
cd terraform-azure/
terraform init
terraform apply -auto-approve

# Create resources in the k8s cluster
cd ../k8s/
az aks get-credentials --resource-group GeekZone --name GeekZoneCluster --admin
kubectl apply -f namespaces.yaml
kubectl apply -f rabbitmq/cluster-operator.yaml
sleep 30
kubectl apply -f rabbitmq/rabbitmq-cluster.yaml
kubectl apply -f rabbitmq/ingress-rabbitmq-mgmt.yaml
export CELERY_BROKER_URL="amqp://$(kubectl -n rabbitmq-system get secret geek-zone-cluster-default-user -o jsonpath='{.data.username}' | base64 --decode):$(kubectl -n rabbitmq-system get secret geek-zone-cluster-default-user -o jsonpath='{.data.password}' | base64 --decode)@$(kubectl -n rabbitmq-system get service geek-zone-cluster -o jsonpath='{.spec.clusterIP}')"
envsubst < celery/celery-secrets.yaml | sponge celery/celery-secrets.yaml
kubectl apply -f celery/
kubectl apply -f postgres/
envsubst < prod/prod-secrets.yaml | sponge prod/prod-secrets.yaml
kubectl apply -f prod/
