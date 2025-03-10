output "name" {
  value = module.backup_policy_blob_storage.name
}
output "vault_id" {
  value = module.backup_policy_blob_storage.vault_id
}
output "backup_repeating_time_intervals" {
  value = module.backup_policy_blob_storage.backup_repeating_time_intervals
}

output "operational_default_retention_duration" {
  value = module.backup_policy_blob_storage.operational_default_retention_duration
}

output "vault_default_retention_duration" {
  value = module.backup_policy_blob_storage.vault_default_retention_duration
}

output "time_zone" {
  value = module.backup_policy_blob_storage.time_zone
}
