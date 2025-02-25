terraform {
  backend "s3" {
    bucket = "fast-food-terraform-state"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
  }
}