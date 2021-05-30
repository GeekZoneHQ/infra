terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "geekzone"

    workspaces {
     name = "dev"
    }
  }
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  map_users       = var.map_users
  subnets         = module.vpc.private_subnets

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  tags = {
    environment = "dev"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_min_size                  = "1"
      asg_max_size                  = "4"
      asg_desired_capacity          = "1"
      root_volume_type              = "gp2"
      root_volume_size              = "20"
      availability_zones            = "data.aws_availability_zones.available.names"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]      
    },
    /*{
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    }, */

  ]

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

