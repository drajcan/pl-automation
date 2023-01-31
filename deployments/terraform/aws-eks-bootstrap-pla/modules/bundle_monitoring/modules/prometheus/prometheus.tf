#
# (Unmanaged) Addon "Prometheus"
#
# Common:         https://prometheus.io/
# Helm Chart:         https://github.com/prometheus-community/helm-charts/tree/prometheus-15.13.0/charts/prometheus
# Helm Chart values:  https://github.com/prometheus-community/helm-charts/blob/prometheus-15.13.0/charts/prometheus/values.yaml
#
module "namespace" {
  source = "../../../kubernetes_namespace"
  name   = "prometheus"
}

resource "helm_release" "main" {
  depends_on = [module.namespace]
  name       = "prometheus"
  namespace  = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "15.13.0" # 2022-Sep-20

  values = [
    file("${path.module}/files/prometheus.yaml")
  ]
}