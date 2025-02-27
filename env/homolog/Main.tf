module "main" {
  source = "../../infra"
  tags = {
    "env" = "homolog",
    "team" = "fast_food"
    terraform  = "true"
    kubernetes = "fast-food-eks-cluster"
  }
}
