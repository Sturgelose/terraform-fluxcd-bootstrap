resource "kubernetes_namespace" "ns" {
  metadata {
    name        = var.namespace.name
    annotations = var.namespace.annotations
  }
}

resource "helm_release" "flux" {
  name       = var.helm.release_name
  repository = var.helm.chart_repository
  chart      = var.helm.chart_name
  version    = var.helm.chart_version

  namespace = kubernetes_namespace.ns.metadata[0].name

  wait          = true
  wait_for_jobs = true

  values = [
    var.custom_values.flux2,
  ]

  set {
    name  = "clusterDomain"
    value = var.cluster_domain
  }

  dynamic "set_list" {
    for_each = length(var.image_pull_secrets) != 0 ? ["this"] : []
    content {
      name  = "imagePullSecrets"
      value = var.image_pull_secrets
    }
  }

  set {
    name  = "watchAllNamespaces"
    value = var.watch_all_namespaces
  }

  set {
    name  = "logLevel"
    value = var.log_level
  }

  set {
    name  = "policies.create"
    value = var.network_policy
  }

  set {
    name  = "multitenancy.enabled"
    value = var.multi_tenancy.enabled
  }

  set {
    name  = "multitenancy.privileged"
    value = var.multi_tenancy.privileged
  }

  set {
    name  = "multitenancy.defaultServiceAccount"
    value = var.multi_tenancy.default_service_account
  }

  depends_on = [kubernetes_namespace.ns]
}

resource "helm_release" "flux_sync" {
  name       = "${var.helm.release_name}-sync"
  repository = var.helm.chart_repository
  chart      = var.helm.chart_name_sync
  version    = var.helm.chart_sync_version

  namespace = kubernetes_namespace.ns.metadata[0].name

  wait          = true
  wait_for_jobs = true

  values = [
    var.custom_values.flux2_sync,
  ]

  set {
    name  = "gitRepository.spec.secretRef.name"
    value = kubernetes_secret.flux_system.metadata[0].name
  }

  set {
    name  = "gitRepository.spec.recurseSubmodules"
    value = var.flux_sync.recurse_submodules
  }

  set {
    name  = "gitRepository.spec.url"
    value = var.flux_sync.git_repository
  }

  set {
    name  = "gitRepository.spec.ref.branch"
    value = var.flux_sync.git_branch
  }

  set {
    name  = "gitRepository.spec.interval"
    value = var.flux_sync.interval
  }

  set {
    name  = "kustomization.spec.interval"
    value = var.flux_sync.interval
  }

  set {
    name  = "kustomization.spec.path"
    value = var.flux_sync.git_path
  }

  set {
    name  = "kustomization.spec.targetNamespace"
    value = kubernetes_namespace.ns.metadata[0].name
  }

  depends_on = [helm_release.flux, kubernetes_namespace.ns]
}

resource "kubernetes_secret" "flux_system" {
  metadata {
    name      = "flux-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  data = var.git_credentials
}