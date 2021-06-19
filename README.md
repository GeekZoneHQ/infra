# Geek.Zone's EKS Cluster

This repo will guide and show you how to deploy and/or maintain the infrastructure that hosts the Geek.Zone Web App. It consists of an EKS cluster provisioned by using Terraform, an open-source infrastructure as code (IaC) software tool. Thanks to the use of declarative configuration files, where the desired state of the infrastructure is codified, Terraform allows building, changing, and versioning infrastructure in a safe, consistent and efficient way.
Terraform keeps track of resources by recording them in a file called terraform.tfstate, which can either be stored locally or remotely. If the terraform.tfstate is hosted remotely, Terraform can also interact with preconfigured Version Control Systems, such as Github. 

There are 4 main commands to manage infrastructure with Terraform:
- "terraform init", which initializes the workfolder, the directory where the configuration files reside.
- "terraform plan", which compares the configuration files with the existing resources, if any, and shows what resouces would need to be created and/or destroyed
- "terraform apply", to create or destroy resources according to the configuration files. This command is normally run after "terraform plan", but can be run straight after "terraform init" as well.
- "terraform destroy", to destroy the infrastructure created and managed by Terraform. 

In order to provision Geek.Zone's EKS cluster you will need to install the Terraform CLI (https://learn.hashicorp.com/tutorials/terraform/install-cli), the  AWS CLI v2 (https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

# Deploying the cluster

1. Configure the AWS CLI to use your credentials by running "aws configure" and passing a value for each key. Alternatively the AWS credentials can be passed in the remote workspace, if the terraform.tfstate is stored remotely in Terraform cloud.
2. Initialize the working directory by running "terraform init". Make sure your terminal is open in that directory.
3. Provision the EKS cluster by running "terraform apply". This will take approximately 10 minutes. Once the command is executed, the outputs will be displayed on the screen.
4. Configure kubectl with the context of the newly deployed EKS cluster by running "aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)". The kubernetes cluster name and region correspond to the output variables showed after the successful Terraform run. You can view these outputs again by running the command "terraform output".
5. Deploy in the newly created EKS cluster the Geek.Zone web app microservices, along with the storage, networking, security, logging and monitoring components. To do this run the following commands:
- "kubectl apply -f k8s/namespaces.yaml"
- "kubectl apply -f k8s/storage-class-aws.yaml"
- "kubectl apply -f k8s/ingress-nginx"
- "kubectl apply -f k8s/logging"
- "kubectl apply -f k8s/metrics"
- "kubectl apply -f k8s/monitoring"
- "kubectl apply -f k8s/rabbitmq"
- "kubectl apply -f k8s/web"
You can then run "kubectl get all --all-namespaces" to check the status of all the resources in the EKS cluster. Once the ingress-controller has been deployed, copy and paste the DNS name of the load balancer (that gets created along with the controller) into the target field of the CNAME records for logging, monitoring, rabbitmq and test.geek.zone in Cloudflair.

To delete all the resources deployed in the EKS cluster, just run the following command:
- "kubectl delete -f k8s/"