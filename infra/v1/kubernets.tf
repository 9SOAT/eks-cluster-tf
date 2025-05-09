resource "kubectl_manifest" "secret" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: my-admin-binding
    roleRef:
      kind: ClusterRole
      name: cluster-admin
      apiGroup: rbac.authorization.k8s.io
    subjects:
      - kind: Group
        name: my-admin
        apiGroup: rbac.authorization.k8s.io
  YAML

  depends_on = [module.eks]
}

resource "kubernetes_namespace" "fast_food_consumer" {
  metadata {
    name = "fast-food-consumer"
  }
}
