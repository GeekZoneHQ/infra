module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  map_users       = var.map_users
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "workers-1.20"
      instance_type                 = "t3.medium"
      asg_min_size                  = "0"
      asg_max_size                  = "0"
      asg_desired_capacity          = "0"
      key_name                      = "geekzone"
      root_volume_type              = "gp2"
      root_volume_size              = "20"
      availability_zones            = "data.aws_availability_zones.available.names"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "workers-1.21"
      instance_type                 = "t3.medium"
      asg_min_size                  = "1"
      asg_desired_capacity          = "1"
      asg_max_size                  = "3"
      root_volume_size              = "20"
      root_volume_type              = "gp2"
      key_name                      = "geekzone"
      availability_zones            = "data.aws_availability_zones.available.names"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }

  ]

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

