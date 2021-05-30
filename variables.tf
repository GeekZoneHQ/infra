variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::098281131088:user/carwyn"
      username = "carwyn"
      groups   = ["system:masters"]  
    },
    {
      userarn  = "arn:aws:iam::098281131088:user/james"
      username = "james"
      groups   = ["system:masters"]  
    },
  ]
} 

variable "db_name" {}     #Database name
variable "db_username" {} #Database username
variable "db_password" {} #Database password
variable "db_port" {}     #Database port