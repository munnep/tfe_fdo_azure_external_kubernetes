resource "helm_release" "kubequery" {
  name             = "kubequery"
  repository       = "https://uptycslabs.github.io/kspm-helm-charts"
  chart            = "kubequery"
  namespace        = "edr-kubequery"
  create_namespace = true

  values = [
    file("${path.module}/kubequery-values.yaml")
  ]

  set = [
    {
      name  = "deployment.spec.hostname"
      value = var.tag_prefix
    }
  ]

  depends_on = [ azurerm_kubernetes_cluster.example ]
}

resource "helm_release" "k8sosquery" {
  name             = "k8sosquery"
  repository       = "https://uptycslabs.github.io/kspm-helm-charts"
  chart            = "k8sosquery"
  namespace        = "edr-k8sosquery"
  create_namespace = true

  values = [
    file("${path.module}/k8sosquery-values.yaml")
  ]

  depends_on = [ azurerm_kubernetes_cluster.example ]
}
