module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.projectName}-eks-cluster"
  cluster_version = var.eksVersion

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id = module.eks-vpc.vpc_id

  attach_cluster_encryption_policy = false  # Default is true
  cluster_endpoint_public_access  = true

  control_plane_subnet_ids = concat(module.eks-vpc.public_subnets, module.eks-vpc.private_subnets)

  cluster_security_group_name        = "${var.projectName}-eks-cluster-sg"

  bootstrap_self_managed_addons = true

  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true


  #override defaults
  create_cloudwatch_log_group   = false
  create_kms_key                = false
  enable_kms_key_rotation       = false
  kms_key_enable_default_policy = false
  enable_irsa                   = false
  cluster_encryption_config = {}
  enable_auto_mode_custom_tags = false

  # EKS Managed Node Group(s)
  node_security_group_description              = "EKS node group security group - used by nodes to communicate with the cluster API Server"
  node_security_group_name                     = "${var.projectName}-eks-node-group-security-group"

  subnet_ids = module.eks-vpc.private_subnets
  eks_managed_node_groups = {
    group1 = {
      name          = "${var.projectName}-node-group"
      ami_type      = "AL2023_x86_64_STANDARD"
      instance_types = [var.instanceType]
      capacity_type = "SPOT"
      min_size      = var.minSize
      max_size      = var.maxSize
      desired_size  = var.desiredSize
    }
  }
}

# Service Account
resource "kubernetes_service_account_v1" "fast_food_catalog_sa" {
  metadata {
    name = "fast-food-catalog-sa"
    namespace = "default"
  }
}

resource "aws_eks_pod_identity_association" "aws_eks_pod_identity_association" {
  cluster_name    = module.eks.cluster_name
  namespace       = "default"
  service_account = kubernetes_service_account_v1.fast_food_catalog_sa.metadata[0].name
  role_arn        = aws_iam_role.pod_assume_role.arn

  depends_on = [kubernetes_service_account_v1.fast_food_catalog_sa, aws_iam_role.pod_assume_role]
}

# Service Account
resource "kubernetes_service_account_v1" "fast_food_consumer_sa" {
  metadata {
    name      = "fast-food-consumer-sa"
    namespace = "default"
  }
}

resource "aws_eks_pod_identity_association" "fast_food_consumer_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "default"
  service_account = kubernetes_service_account_v1.fast_food_consumer_sa.metadata[0].name
  role_arn        = aws_iam_role.fast_food_consumer_pod_role.arn

  depends_on = [
    kubernetes_service_account_v1.fast_food_consumer_sa,
    aws_iam_role.fast_food_consumer_pod_role
  ]
}