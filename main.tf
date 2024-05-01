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

  namespace = kubernetes_namespace.ns.metadata.name

  wait          = true
  wait_for_jobs = true

  values = [
    var.custom_values,
  ]

  set {
    name  = "clusterDomain"
    value = var.cluster_domain
  }

  set {
    name  = "imagePullSecrets"
    value = jsonencode(var.image_pull_secrets)
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
}

resource "kubernetes_manifest" "gitrepo" {
  manifest = {
    "apiVersion" = "source.toolkit.fluxcd.io/v1"
    "kind"       = "GitRepository"
    "metadata" = {
      "name"      = "flux-system"
      "namespace" = kubernetes_namespace.ns.metadata.name
    }
    "spec" = {
      "interval"          = var.flux_sync.interval
      "url"               = var.flux_sync.git_repository
      "recurseSubmodules" = var.flux_sync.recurse_submodules
      "secretRef" = {
        "name" = kubernetes_secret.flux_system.metadata.name
      }
      "ref" = {
        "branch" = var.flux_sync.git_branch
      }
    }
  }

  wait {
    fields = {
      "status.conditions.type"   = "Ready"
      "status.conditions.status" = "True"
    }
  }

  depends_on = [
    helm_release.flux,
    kukubernetes_secret.flux_system,
  ]
}

resource "kubernetes_manifest" "flux_system_sync" {
  manifest = {
    "apiVersion" = "source.toolkit.fluxcd.io/v1"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "flux-system"
      "namespace" = kubernetes_namespace.ns.metadata.name
    }
    "spec" = {
      "interval"        = var.flux_sync.interval
      "path"            = var.flux_sync.git_path
      "targetNamespace" = kubernetes_namespace.ns.metadata.name
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = kubernetes_manifest.gitrepo.manifest.metadata.name
      }
    }
  }

  wait {
    fields = {
      "status.conditions.type"   = "Ready"
      "status.conditions.status" = "True"
    }
  }

  depends_on = [helm_release.this]
}

resource "kubernetes_secret" "flux_system" {
  metadata {
    name      = "flux-secret"
    namespace = kubernetes_namespace.ns.metadata.name
  }

  data = var.git_credentials
}