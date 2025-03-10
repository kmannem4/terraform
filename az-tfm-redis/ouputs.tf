output "redis_name" {
  value       = { for key, redis in azurerm_redis_cache.redis : key => redis.name }
  description = "Redis host name"
}
