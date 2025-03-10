output "id" {
  description = "The ID of the SignalR service."
  value       = module.signalr.id
}

output "hostname" {
  description = "The FQDN of the SignalR service"
  value       = module.signalr.hostname
}

output "ip_address" {
  description = "The publicly accessible IP of the SignalR service"
  value       = module.signalr.ip_address
}

output "public_port" {
  description = "The publicly accessible port of the SignalR service which is designed for browser/client use."
  value       = module.signalr.public_port
}

output "server_port" {
  description = "The publicly accessible port of the SignalR service which is designed for customer server side use."
  value       = module.signalr.server_port
}

output "primary_access_key" {
  description = "The primary access key for the SignalR service."
  value       = module.signalr.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the SignalR service."
  value       = module.signalr.primary_connection_string
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the SignalR service."
  value       = module.signalr.secondary_access_key
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the SignalR service."
  value       = module.signalr.secondary_connection_string
  sensitive   = true
}