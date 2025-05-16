locals {
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

module "ecr_fast_food" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.projectName
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
  repository_lifecycle_policy = local.repository_lifecycle_policy
  tags = var.tags
}

module "ecr_fast_food_catalog" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.projectName}-catalog"
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
  repository_lifecycle_policy = local.repository_lifecycle_policy
  tags = var.tags
}

module "ecr_fast_food_order" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.projectName}-order"
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
  repository_lifecycle_policy = local.repository_lifecycle_policy
  tags = var.tags
}

module "ecr_fast_food_consumer" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "${var.projectName}-consumer"
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
  repository_lifecycle_policy = local.repository_lifecycle_policy
  tags = var.tags
}

module "ecr_helm_charts" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "helm-charts/micro-service"
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
  repository_lifecycle_policy = local.repository_lifecycle_policy
  tags = var.tags
}
