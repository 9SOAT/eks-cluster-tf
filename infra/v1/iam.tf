resource "aws_iam_role" "eks_admin_role" {
  name = "fast-food-eks-admin-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_admin" {
  name = "AmazonEKSAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
  role       = aws_iam_role.eks_admin_role.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_user" "manager" {
  name = "manager"
}

resource "aws_iam_policy" "eks_assume_admin" {
  name = "AmazonEKSAssumeAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.eks_admin_role.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "manager" {
  user       = aws_iam_user.manager.name
  policy_arn = aws_iam_policy.eks_assume_admin.arn
}

# Best practice: use IAM roles due to temporary credentials`
resource "aws_eks_access_entry" "manager" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_role.eks_admin_role.arn
  kubernetes_groups = ["my-admin"]
}


resource "aws_iam_policy" "secrets_manager_read_only" {
  name = "SecretsManagerReadOnly"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      "Resource": "*"
    }]
  })
}

resource "aws_iam_role" "pod_assume_role" {
  name = "EKSPodAssumeRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "pods.eks.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.pod_assume_role.name
  policy_arn = aws_iam_policy.secrets_manager_read_only.arn
}

resource "aws_iam_policy" "dynamodb_consumer_access" {
  name = "FastFoodConsumerDynamoAccess"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "arn:aws:dynamodb:${var.awsRegion}:${data.aws_caller_identity.current.account_id}:table/consumer"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "fast_food_consumer_pod_role" {
  name = "fast-food-consumer-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "pods.eks.amazonaws.com"
      },
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamo_to_consumer_pod_role" {
  role       = aws_iam_role.fast_food_consumer_pod_role.name
  policy_arn = aws_iam_policy.dynamodb_consumer_access.arn
}