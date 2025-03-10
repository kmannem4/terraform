output "redis_name" {
  value       = module.redis.redis_name["test-redis"]
  description = "Redis host name"
}
