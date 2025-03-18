module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.projectName
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gh_terraform"]
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
  tags = var.tags
}
