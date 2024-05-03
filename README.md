# FluxCD Terraform/OpenTofu Bootstrap Module

This module sets up FluxCD by using a HelmChart through Terraform or OpenTofu.

This projects is an alternative to the official FluxCD provider as it aims to be more lightweight.
The original provider creates all the resources directly in Kubernetes, generating lengthy diffs and slow plans.

By using a HelmReleases under the hood, the only diffs should only be the values of the Helm Chart, helping in speed and management.

## Known Issues

### Using the Kubernetes provider

It is not possible to install the GitRepository and Kustomization files in the module as it tries to validate the CRDs in the server that do not exist (yet). Instead we are installing two different Helm Charts that help to avoid this validation in the Kubernetes provider.

### Chart installation valid while the Flux resources are not ready

This chart installs a GitRepository and a Kustomization resources to configure the main loop of the GitOps sync. Both are being installed via the `flux-sync` chart.
However, sometimes Helm might assume that the resources are ready when they are in fact failing to connect to the upstream github repo with the GitOps declarations.

The main reason is that both Kubernetes nor Helm have a standard way to validate that a resource's status is "OK" for Resources based in CRDs.
As a result, Helm doesn't make sure that the GitRepository and Kustomizations have a valid state.

This is a known issue, and we can potentially mitigate it with a post-install/post-upgrade hook to double-check it in-cluster.

<!-- BEGIN_TF_DOCS -->


## Example

```hcl
resource "kind_cluster" "this" {
    name = "test-cluster"
}

module "flux" {
  source = "../"

  flux_sync = {
    git_repository = "https://github.com/Sturgelose/flux-structure-example.git"
    git_path = "./clusters/housy"
  }

  # Format defined in Flux Documentation: 
  # https://fluxcd.io/flux/components/source/gitrepositories/#secret-reference
  git_credentials = {
    username = "user"
    password = "pass"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | Domain of the cluster. | `string` | `"cluster.local"` | no |
| <a name="input_custom_values"></a> [custom\_values](#input\_custom\_values) | Extra values to costumize the HelmChart with. | <pre>object({<br>    flux_sync = optional(string, "")<br>    flux      = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_flux_sync"></a> [flux\_sync](#input\_flux\_sync) | Configuration to authenticate and sync against a Git repository. | <pre>object({<br>    git_repository     = string<br>    git_branch         = optional(string, "main")<br>    git_path           = string<br>    interval           = optional(string, "1m0s")<br>    recurse_submodules = optional(bool, false)<br>  })</pre> | n/a | yes |
| <a name="input_git_credentials"></a> [git\_credentials](#input\_git\_credentials) | Credentials to authenticate against the Git repository. | `map(string)` | n/a | yes |
| <a name="input_helm"></a> [helm](#input\_helm) | Configuration to install FluxCD via a HelmChart. | <pre>object({<br>    chart_repository   = optional(string, "https://fluxcd-community.github.io/helm-charts")<br>    chart_name         = optional(string, "flux2")<br>    chart_name_sync    = optional(string, "flux2-sync")<br>    chart_version      = optional(string, "2.12.4")<br>    chart_sync_version = optional(string, "1.8.2")<br>    release_name       = optional(string, "flux-system")<br>  })</pre> | `{}` | no |
| <a name="input_image_pull_secrets"></a> [image\_pull\_secrets](#input\_image\_pull\_secrets) | Image Pull secrets. | `list(string)` | `[]` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for toolkit components. | `string` | `"info"` | no |
| <a name="input_multi_tenancy"></a> [multi\_tenancy](#input\_multi\_tenancy) | Configuration to enable Multi Tenancy in Flux. | <pre>object({<br>    enabled                 = optional(bool, false)<br>    default_service_account = optional(string, "default")<br>    privileged              = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where to install Flux. | <pre>object({<br>    name        = optional(string, "flux-system")<br>    annotations = optional(map(string), {})<br>  })</pre> | `{}` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Deny ingress access to the toolkit controllers from other namespaces using network policies. | `bool` | `true` | no |
| <a name="input_watch_all_namespaces"></a> [watch\_all\_namespaces](#input\_watch\_all\_namespaces) | If true watch for custom resources in all namespaces. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_flux_helm_values"></a> [flux\_helm\_values](#output\_flux\_helm\_values) | Computed values for Flux Chart |
| <a name="output_flux_sync_helm_values"></a> [flux\_sync\_helm\_values](#output\_flux\_sync\_helm\_values) | Computed values for Flux Sync Chart |  
<!-- END_TF_DOCS -->