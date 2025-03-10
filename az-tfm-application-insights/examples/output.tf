# Application insights ID OUTPUT VALUE
output "app_insights_id" {
  value = module.application_insights.app_insights_id
}

output "instrumentation_key" {
  value = module.application_insights.instrumentation_key
  sensitive = true
}

output "application_insight_name" {
  value = module.application_insights.application_insight_name
}

output "location" {
  value = module.application_insights.location
}

output "local_authentication_disabled" {
  value = module.application_insights.local_authentication_disabled
}

output "application_type" {
  value = module.application_insights.application_type
}

output "retention_in_days" {
  value = module.application_insights.retention_in_days
}