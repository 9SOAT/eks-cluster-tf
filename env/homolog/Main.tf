module "main" {
  source = "../../infra/v1"
  tags = {
    "env"      = "homolog",
    "team"     = "fast_food"
    terraform  = "true"
    kubernetes = "fast-food-eks-cluster"
  }
}
