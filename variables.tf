variable "helm" {
  type = object({
    chart_repository = optional(string, "https://fluxcd-community.github.io/helm-charts")
    chart_name       = optional(string, "flux")
    chart_version    = optional(string, "2.12.4")
    release_name     = optional(string, "flux-system")
  })
  description = "Configuration to install FluxCD via a HelmChart."
}

variable "flux_sync" {
  type = object({
    interval           = optional(string, "1m0s")
    git_repository     = string
    git_branch         = optional(string, "main")
    git_path           = string
    recurse_submodules = optional(bool, false)
  })
  description = "Configuration to authenticate and sync against a Git repository."
}

variable "git_credentials" {
  type        = map(string)
  sensitive   = true
  description = "Credentials to authenticate against the Git repository."
}

variable "namespace" {
  type = object({
    name        = string
    annotations = optional(map(string), {})
  })
  default = {
    name = "flux-system"
  }
  description = "Namespace where to install Flux."
}

variable "custom_values" {
  type        = string
  default     = ""
  description = "Extra values to costumize the HelmChart with."
}

variable "cluster_domain" {
  type        = string
  default     = "cluster.local"
  description = "Domain of the cluster."
}

variable "image_pull_secrets" {
  type        = list(string)
  default     = []
  description = "Image Pull secrets."
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Log level for toolkit components."
}

variable "network_policy" {
  type        = bool
  default     = true
  description = "Deny ingress access to the toolkit controllers from other namespaces using network policies."
}

variable "watch_all_namespaces" {
  type        = bool
  default     = true
  description = "If true watch for custom resources in all namespaces."
}

variable "multi_tenancy" {
  type = object({
    enabled                 = optional(bool, false)
    default_service_account = optional(string, "default")
    privileged              = optional(bool, true)
  })
  description = "Configuration to enable Multi Tenancy in Flux."
}