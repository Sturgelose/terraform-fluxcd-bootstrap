output "flux_helm_values" {
  value       = helm_release.flux_base.values
  description = "Computed values for Flux Chart"
}

output "flux_sync_helm_values" {
  value       = helm_release.flux_sync.values
  description = "Computed values for Flux Sync Chart"
}