# FluxCD Terraform/OpenTofu Installer

This module sets up FluxCD by using a HelmChart through Terraform or OpenTofu.

This projects is an alternative to the official FluxCD provider as it aims to be more lightweight.
The original provider creates all the resources directly in Kubernetes, generating lengthy diffs and slow plans.

By using a HelmRelease under the hood, the only diffs should only be the values of the Helm Chart, helping in speed and management.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~>2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~>2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~>2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~>2 |

## Resources

| Name | Type |
|------|------|
| [helm_release.flux](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.flux_system_sync](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.gitrepo](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.flux_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Domain of the cluster. | `string` | `"cluster.local"` | no |
| <a name="input_custom_values"></a> [custom\_values](#input\_custom\_values) | Extra values to costumize the HelmChart with. | `string` | `""` | no |
| <a name="input_flux_sync"></a> [flux\_sync](#input\_flux\_sync) | Configuration to authenticate and sync against a Git repository. | <pre>object({<br>    interval           = optional(string, "1m0s")<br>    git_repository     = string<br>    git_branch         = optional(string, "main")<br>    git_path           = string<br>    recurse_submodules = optional(bool, false)<br>  })</pre> | n/a | yes |
| <a name="input_git_credentials"></a> [git\_credentials](#input\_git\_credentials) | Credentials to authenticate against the Git repository. | `map(string)` | n/a | yes |
| <a name="input_helm"></a> [helm](#input\_helm) | Configuration to install FluxCD via a HelmChart. | <pre>object({<br>    chart_repository = optional(string, "https://fluxcd-community.github.io/helm-charts")<br>    chart_name       = optional(string, "flux")<br>    chart_version    = optional(string, "2.12.4")<br>    release_name     = optional(string, "flux-system")<br>  })</pre> | n/a | yes |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | Image Pull secrets. | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for toolkit components. | `string` | `"info"` | no |
| <a name="input_multi_tenancy"></a> [multi\_tenancy](#input\_multi\_tenancy) | Configuration to enable Multi Tenancy in Flux. | <pre>object({<br>    enabled                 = optional(bool, false)<br>    default_service_account = optional(string, "default")<br>    privileged              = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Flux. | <pre>object({<br>    name        = string<br>    annotations = optional(map(string), {})<br>  })</pre> | <pre>{<br>  "name": "flux-system"<br>}</pre> | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Deny ingress access to the toolkit controllers from other namespaces using network policies. | `bool` | `true` | no |
| <a name="input_watch_all_namespaces"></a> [watch\_all\_namespaces](#input\_watch\_all\_namespaces) | If true watch for custom resources in all namespaces. | `bool` | `true` | no |
<!-- END_TF_DOCS -->