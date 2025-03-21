module "main" {
  source = "../../infra/v1"
  tags = {
    Environment = "homolog",
    Team        = "fast_food"
    Terraform   = "true"
    Kubernetes  = "fast-food-eks-cluster"
  }
}
