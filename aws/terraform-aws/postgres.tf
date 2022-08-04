resource "aws_db_subnet_group" "geekzone" {

  name       = "geekzone"
  subnet_ids = module.vpc.database_subnets

}
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.db_name
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}

################################################################################
# RDS Module
################################################################################

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.db_name
  version = "4.7.0"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.1"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"          # DB option group
  instance_class       = "db.t2.micro"

  allocated_storage     = 10
  max_allocated_storage = 20
  storage_encrypted     = false
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  port                  = var.db_port

  multi_az               = false
  db_subnet_group_name   = "geekzone"
  subnet_ids             = module.vpc.database_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  # enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = false
  performance_insights_retention_period = 0
  create_monitoring_role                = false
  monitoring_interval                   = 0

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }

  depends_on = [
    aws_db_subnet_group.geekzone
  ]

}
