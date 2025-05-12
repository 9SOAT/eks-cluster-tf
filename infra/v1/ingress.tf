locals {
  ingress_yaml = <<-YAML
controller:
  replicaCount: 2
  minAvailable: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi
  autoscaling:
    enabled: true
    annotations: {}
    minReplicas: 2
    maxReplicas: 6
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 60
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-type: nlb
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    targetPorts:
      http: http
      https: http
  YAML
}


resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.12.2"
  values = [local.ingress_yaml]
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "fast-food-catalog-ingress"
    namespace = "default"
    annotations = {
      "nginx.ingress.kubernetes.io/use-regex" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/catalog(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "fast-food-catalog-svc"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}