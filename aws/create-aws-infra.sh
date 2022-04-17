#!/bin/sh -e

# Launch k8s cluster in AWS 
cd terraform-aws/
terraform init
terraform apply -auto-approve

# Create resources in the k8s cluster
cd ../k8s/
rm ~/.kube/config
aws eks --region eu-west-2 update-kubeconfig --name GeekZoneCluster 
kubectl apply -f namespaces.yaml
envsubst < sealed-secrets/master-key-secret.yaml | sponge sealed-secrets/master-key-secret.yaml
kubectl apply -f sealed-secrets/master-key-secret.yaml
kubectl apply -f sealed-secrets/controller.yaml
kubectl apply -f sealed-secrets/sealed-secrets.yaml
kubectl apply -f aws-storage-class.yaml
kubectl apply -f keda-2.5.0.yaml
kubectl apply -f external-dns/
kubectl apply -f ingress-nginx/
kubectl apply -f rabbitmq/cluster-operator.yaml
sleep 30
kubectl apply -f rabbitmq/rabbitmq-cluster.yaml
kubectl apply -f rabbitmq/ingress-rabbitmq-mgmt.yaml
export CELERY_BROKER_URL="amqp://$(kubectl -n rabbitmq-system get secret geek-zone-cluster-default-user -o jsonpath='{.data.username}' | base64 --decode):$(kubectl -n rabbitmq-system get secret geek-zone-cluster-default-user -o jsonpath='{.data.password}' | base64 --decode)@$(kubectl -n rabbitmq-system get service geek-zone-cluster -o jsonpath='{.spec.clusterIP}')"
envsubst < celery/celery-secrets.yaml | sponge celery/celery-secrets.yaml
kubectl apply -f celery/
envsubst < prod/prod-secrets.yaml | sponge prod/prod-secrets.yaml
kubectl apply -f prod/
