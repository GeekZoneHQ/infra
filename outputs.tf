output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "this_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.db.this_db_instance_endpoint
}

output "this_db_instance_name" {
  description = "The database name"
  value       = module.db.this_db_instance_name
}

output "this_db_instance_username" {
  description = "The master username for the database"
  value       = module.db.this_db_instance_username
}

output "this_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.db.this_db_instance_password
  sensitive   = true
}

output "this_db_instance_port" {
  description = "The database port"
  value       = module.db.this_db_instance_port
}