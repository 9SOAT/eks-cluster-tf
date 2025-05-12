variable "awsRegion" {
    default = "us-east-1"
}

variable "cidr_block" {
    type = string
    default = "10.10.0.0/16"
}

variable "projectName" {
    default = "fast-food"
}

variable "instanceType" {
    default = "t3.medium"
}

variable "minSize" {
    default = 1
}

variable "maxSize" {
    default = 2
}

variable "desiredSize" {
    default = 1
}

variable "eksVersion" {
    default = "1.32"
}

variable "tags" {
    type = map(string)
    default = {
        Terraform  = "true"
        Kubernetes = "fast-food-eks-cluster"
    }
    description = "Tags to apply to all resources"
}
