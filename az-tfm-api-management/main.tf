resource "azurerm_api_management" "apim" {
  name                = var.api_management["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.api_management["publisher_name"]
  publisher_email     = var.api_management["publisher_email"]
  sku_name            = "${var.api_management["sku_tier"]}_${var.api_management["sku_capacity"]}"
  tags                = var.tags
  dynamic "additional_location" {
    for_each = var.api_management["additional_location"] == null ? [] : [var.api_management["additional_location"]]
    content {
      location             = additional_location.value["location"]
      capacity             = additional_location.value["capacity"]
      zones                = additional_location.value["zones"]
      public_ip_address_id = additional_location.value["public_ip_address_id"]
      dynamic "virtual_network_configuration" {
        for_each = additional_location.value["virtual_network_configuration"] == null ? [] : [additional_location.value["virtual_network_configuration"]]
        content {
          subnet_id = additional_location.value.virtual_network_configuration["subnet_id"]
        }
      }
    }
  }
  dynamic "certificate" {
    for_each = var.api_management["certificate"] == null ? [] : [var.api_management["certificate"]]
    content {
      encoded_certificate  = certificate.value["encoded_certificate"]
      certificate_password = certificate.value["certificate_password"]
      store_name           = certificate.value["store_name"]
    }
  }
  client_certificate_enabled = var.api_management["client_certificate_enabled"]
  dynamic "delegation" {
    for_each = var.api_management["delegation"] == null ? [] : [var.api_management["delegation"]]
    content {
      subscriptions_enabled = delegation.value["subscriptions_enabled"]
      url                   = delegation.value["url"]
      validation_key        = delegation.value["validation_key"]
    }
  }
  gateway_disabled = var.api_management["gateway_disabled"]
  min_api_version  = var.api_management["min_api_version"]
  
  dynamic "identity" {
    for_each = var.api_management["identity"] == null ? [] : [var.api_management["identity"]]
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identity_ids"]
    }
  }
  zones= var.api_management["zones"]
  dynamic "hostname_configuration" {
    for_each = var.api_management["hostname_configuration"] == null ? [] : [var.api_management["hostname_configuration"]]
    content {
      developer_portal {
        host_name                       = hostname_configuration.value["developer_portal"]["hostname"]
        key_vault_id                    = hostname_configuration.value["developer_portal"]["key_vault_id"]
        certificate                     = hostname_configuration.value["developer_portal"]["certificate"]
        certificate_password            = hostname_configuration.value["developer_portal"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["developer_portal"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["developer_portal"]["ssl_keyvault_identity_client_id"]
      }
      management {
        host_name                       = hostname_configuration.value["management"]["hostname"]
        key_vault_id                    = hostname_configuration.value["management"]["key_vault_id"]
        certificate                     = hostname_configuration.value["management"]["certificate"]
        certificate_password            = hostname_configuration.value["management"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["management"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["management"]["ssl_keyvault_identity_client_id"]
      }
      portal {
        host_name                       = hostname_configuration.value["portal"]["hostname"]
        key_vault_id                    = hostname_configuration.value["portal"]["key_vault_id"]
        certificate                     = hostname_configuration.value["portal"]["certificate"]
        certificate_password            = hostname_configuration.value["portal"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["portal"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["portal"]["ssl_keyvault_identity_client_id"]
      }
      scm {
        host_name                       = hostname_configuration.value["scm"]["hostname"]
        key_vault_id                    = hostname_configuration.value["scm"]["key_vault_id"]
        certificate                     = hostname_configuration.value["scm"]["certificate"]
        certificate_password            = hostname_configuration.value["scm"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["scm"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["scm"]["ssl_keyvault_identity_client_id"]
      }
      proxy {
        host_name                       = hostname_configuration.value["proxy"]["hostname"]
        key_vault_id                    = hostname_configuration.value["proxy"]["key_vault_id"]
        certificate                     = hostname_configuration.value["proxy"]["certificate"]
        certificate_password            = hostname_configuration.value["proxy"]["certificate_password"]
        negotiate_client_certificate    = hostname_configuration.value["proxy"]["negotiate_client_certificate"]
        ssl_keyvault_identity_client_id = hostname_configuration.value["proxy"]["ssl_keyvault_identity_client_id"]
      }
    }
  }
  notification_sender_email = var.api_management["notification_sender_email"]
  dynamic "protocols" {
    for_each = var.api_management["protocols"] == null ? [] : [var.api_management["protocols"]]
    content {
      enable_http2 = protocols.value["enable_http2"]
  }
  }
  dynamic "security" {
    for_each = var.api_management["security"] == null ? [] : [var.api_management["security"]]
    content {
      enable_backend_ssl30 = security.value["enable_backend_ssl30"]
      enable_backend_tls10 = security.value["enable_backend_tls10"]
      enable_backend_tls11 = security.value["enable_backend_tls11"]
      enable_frontend_ssl30 = security.value["enable_frontend_ssl30"]
      enable_frontend_tls10 = security.value["enable_frontend_tls10"]
      enable_frontend_tls11 = security.value["enable_frontend_tls11"]
      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled     = security.value["tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled     = security.value["tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled"]
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled       = security.value["tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled       = security.value["tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled"]
      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes128_cbc_sha256_ciphers_enabled"]
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled             = security.value["tls_rsa_with_aes128_cbc_sha_ciphers_enabled"]
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes128_gcm_sha256_ciphers_enabled"]
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled          = security.value["tls_rsa_with_aes256_gcm_sha384_ciphers_enabled"]
      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled          = security.value["tls_rsa_with_aes256_cbc_sha256_ciphers_enabled"]
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled             = security.value["tls_rsa_with_aes256_cbc_sha_ciphers_enabled"]
      triple_des_ciphers_enabled = security.value["triple_des_ciphers_enabled"]
  }
  }
  dynamic "sign_in" {
    for_each = var.api_management["sign_in"] == null ? [] : [var.api_management["sign_in"]]
    content {
    enabled = sign_in.value["enabled"]
    }
  }
  dynamic "sign_up" {
    for_each = var.api_management["sign_up"] == null ? [] : [var.api_management["sign_up"]]
    content {
      enabled = sign_up.value["enabled"]
      terms_of_service {
        enabled = sign_up.value["terms_of_service"]["enabled"]
        consent_required = sign_up.value["terms_of_service"]["consent_required"]
        text = sign_up.value["terms_of_service"]["text"]
      }
      }
  }
  dynamic "tenant_access" {
    for_each = var.api_management["tenant_access"] == null ? [] : [var.api_management["tenant_access"]]
    content {
      enabled = tenant_access.value["enabled"]
    }
  }
  public_ip_address_id = var.api_management["public_ip_address_id"]
  public_network_access_enabled = var.api_management["public_network_access_enabled"]
  virtual_network_type = var.api_management["virtual_network_type"]
  dynamic "virtual_network_configuration" {
   for_each = var.api_management["virtual_network_configuration"] == null ? [] : [var.api_management["virtual_network_configuration"]]
   content {
        subnet_id = virtual_network_configuration.value["subnet_id"]
      }
   }  
}