output "servicebus_location" {
  value = module.servicebus.servicebus_location
}

output "servicebus_namespace_id" {
  value = module.servicebus.servicebus_namespace_id
}

output "servicebus_queue_id" {
  value = module.servicebus.servicebus_queue_id
}

output "servicebus_topic_id" {
  value = module.servicebus.servicebus_topic_id
}

output "servicebus_topic_subscription_id" {
  value = module.servicebus.servicebus_topic_subscription_id
}

output "servicebus_namespace_name" {
  value = module.servicebus.servicebus_namespace_name
}

output "servicebus_queues" {
  description = "servicebus queues description"
  value       = module.servicebus.servicebus_queues
}

output "var_servicebus_queues" {
  description = "Variable servicebus queues description"
  value       = var.queue_vars
}

output "servicebus_topics" {
  description = "servicebus topics description"
  value       = module.servicebus.servicebus_topics
}

output "var_servicebus_topicss" {
  description = "Variable servicebus topics description"
  value       = var.topic_vars
}