output "id" {
  description = "The ID of the Load Test."
  value       = module.load_test.id
}

output "data_plane_uri" {
  description = "Resource data plane URI."
  value       = module.load_test.data_plane_uri
}

output "description" {
  description = "The description of the Load Test."
  value       = module.load_test.description
}

output "test_name" {
  description = "The name of the Test."
  value       = module.load_test.test_name
}

output "test_location" {
  description = "The location of the Test."
  value       = module.load_test.test_location
}

output "test_encryption" {
  description = "The encryption of the Test."
  value       = module.load_test.test_encryption
}

