variable "tags" {
  description = "Tags that should be present on the AKS cluster resources"
  type = map(string)
}
variable "location" {
  type = string
  description = "value to create location"
}
variable "resource_group_name"{
  type = string
  description = "value to create resource group"
} 
variable "api_management" {
  description = "The configuration of API Management."
  type = object({
    name                     = string
    publisher_name           = string
    publisher_email          = string
    sku_tier                 = string
    sku_capacity             = number
    additional_location      = optional(list(object({
      location            = string
      capacity            = optional(number)
      zones               = optional(number)
      public_ip_adress_id = optional(string)
      virtual_network_configuration = optional(list(object({
        subnet_id = string
      })))
      gateway_disabled = optional(string)
    })))
    certificate = optional(list(object({
      encoded_certificate  = string
      store_name           = string
      certificate_password = optional(string)
    })))
    client_certificate_enabled = optional(string)
    delegation = optional(list(object({
      subscriptions_enabled = optional(bool, false)
      url                   = optional(string)
      validation_key        = optional(string)
    })))
    gateway_disabled = optional(bool, false)
    min_api_version   = optional(string)
    zones              = optional(list(string))
    identity = optional(list(object({
      type         = string
      identity_ids = optional(string)
    })))
    hostname_configuration = optional(list(object({
      management = optional(list(object({
        hostname                        = string
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool, false)
        ssl_keyvault_identity_client_id = optional(string)
      })))
      portal = optional(list(object({
        hostname                        = string
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool, false)
        ssl_keyvault_identity_client_id = optional(string)
      })))
      developer_portal = optional(list(object({
        hostname                        = string
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool, false)
        ssl_keyvault_identity_client_id = optional(string)
      })))
      porxy = optional(list(object({
        default_ssl_binding             = optional(bool, false)
        hostname                        = string
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool, false)
        ssl_keyvault_identity_client_id = optional(string)
      })))
      scm = optional(list(object({
        hostname                        = string
        key_vault_id                    = optional(string)
        certificate                     = optional(string)
        certificate_password            = optional(string)
        negotiate_client_certificate    = optional(bool, false)
        ssl_keyvault_identity_client_id = optional(string)
      })))
    })))
    notification_sender_email = optional(string)
    protocols = optional(list(object({
      enable_http2 = optional(bool, false)
    })))
    security = optional(list(object({
      enable_backend_ssl30                                    = optional(bool, false)
      enable_backend_tls10                                    = optional(bool, false)
      enable_backend_tls11                                    = optional(bool, false)
      enable_frontend_ssl30                                   = optional(bool, false)
      enable_frontend_tls10                                   = optional(bool, false)
      enable_frontend_tls11                                   = optional(bool, false)
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled     = optional(bool, false)
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled     = optional(bool, false)
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled       = optional(bool, false)
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled       = optional(bool, false)
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled          = optional(bool, false)
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled             = optional(bool, false)
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled          = optional(bool, false)
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled          = optional(bool, false)
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled          = optional(bool, false)
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled             = optional(bool, false)
      triple_des_ciphers_enabled                              = optional(string)
    })))
    sign_in = optional(list(object({
      enabled = string
    })))
    sign_up = optional(list(object({
      enabled = string
      terms_of_service = list(object({
        consent_required = string
        enabled          = string
        text             = optional(string)
      }))
    })))
    tenant_access = optional(list(object({
      enabled = string
    })))
    public_ip_address_id       = optional(string)
    public_network_access_enabled = optional(string)
    virtual_network_type      = optional(string)
    virtual_network_configuration = optional(list(object({
      subnet_id = string
    })))
  })
}