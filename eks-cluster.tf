 terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "geekzone"

    workspaces {
     name = "test"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.18"
  map_users       = var.map_users
  subnets         = module.vpc.private_subnets

  tags = {
    environment = "test"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_min_size                  = "1"
      asg_max_size                  = "1"
      asg_desired_capacity          = "1"
      root_volume_type              = "gp2"
      root_volume_size              = "8"
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


resource "kubernetes_namespace" "example" {
  metadata {          
      name = "${PR_NUMBER}-${CIRCLE_PROJECT_REPONAME}"      
  }
  timeouts {
    delete = "5m"  
  }
}


 