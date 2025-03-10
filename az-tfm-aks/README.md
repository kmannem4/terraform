<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to create AKS Cluster resource in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl
data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  location                            = coalesce(var.location, data.azurerm_resource_group.rg.location)
  name                                = local.cluster_name
  resource_group_name                 = data.azurerm_resource_group.rg.name
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  azure_policy_enabled                = var.azure_policy_enabled
  disk_encryption_set_id              = var.disk_encryption_set_id
  dns_prefix                          = var.prefix
  image_cleaner_enabled               = var.image_cleaner_enabled
  image_cleaner_interval_hours        = var.image_cleaner_interval_hours
  kubernetes_version                  = var.kubernetes_version
  local_account_disabled              = var.local_account_disabled
  node_os_channel_upgrade             = var.node_os_channel_upgrade
  node_resource_group                 = var.node_resource_group
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  open_service_mesh_enabled           = var.open_service_mesh_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  run_command_enabled                 = var.run_command_enabled
  sku_tier                            = var.sku_tier
  support_plan                        = var.support_plan
  tags                                = var.tags
  workload_identity_enabled           = var.workload_identity_enabled

  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? [] : ["default_node_pool_manually_scaled"]

    content {
      name                         = var.agents_pool_name
      vm_size                      = var.agents_size
      enable_auto_scaling          = var.enable_auto_scaling
      enable_host_encryption       = var.enable_host_encryption
      enable_node_public_ip        = var.enable_node_public_ip
      fips_enabled                 = var.default_node_pool_fips_enabled
      max_count                    = null
      max_pods                     = var.agents_max_pods
      min_count                    = null
      node_count                   = var.agents_count
      node_labels                  = var.agents_labels
      node_taints                  = var.agents_taints
      only_critical_addons_enabled = var.only_critical_addons_enabled
      orchestrator_version         = var.orchestrator_version
      os_disk_size_gb              = var.os_disk_size_gb
      os_disk_type                 = var.os_disk_type
      os_sku                       = var.os_sku
      pod_subnet_id                = var.pod_subnet_id
      proximity_placement_group_id = var.agents_proximity_placement_group_id
      scale_down_mode              = var.scale_down_mode
      snapshot_id                  = var.snapshot_id
      tags                         = merge(var.tags, var.agents_tags)
      temporary_name_for_rotation  = var.temporary_name_for_rotation
      type                         = var.agents_type
      ultra_ssd_enabled            = var.ultra_ssd_enabled
      vnet_subnet_id               = var.vnet_subnet_id
      zones                        = var.agents_availability_zones

      dynamic "kubelet_config" {
        for_each = var.agents_pool_kubelet_configs

        content {
          allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
          container_log_max_line    = kubelet_config.value.container_log_max_line
          container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
          cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
          cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
          cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
          image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
          image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
          pod_max_pid               = kubelet_config.value.pod_max_pid
          topology_manager_policy   = kubelet_config.value.topology_manager_policy
        }
      }
      dynamic "linux_os_config" {
        for_each = var.agents_pool_linux_os_configs

        content {
          swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
          transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
          transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled

          dynamic "sysctl_config" {
            for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs

            content {
              fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
              fs_file_max                        = sysctl_config.value.fs_file_max
              fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
              fs_nr_open                         = sysctl_config.value.fs_nr_open
              kernel_threads_max                 = sysctl_config.value.kernel_threads_max
              net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
              net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
              net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
              net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
              net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
              net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
              net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
              net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
              net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
              net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
              net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
              net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
              net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
              net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
              net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
              net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
              net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
              net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
              net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
              net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
              net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
              vm_max_map_count                   = sysctl_config.value.vm_max_map_count
              vm_swappiness                      = sysctl_config.value.vm_swappiness
              vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
            }
          }
        }
      }
      dynamic "upgrade_settings" {
        for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]

        content {
          max_surge = var.agents_pool_max_surge
        }
      }
    }
  }
  dynamic "default_node_pool" {
    for_each = var.enable_auto_scaling == true ? ["default_node_pool_auto_scaled"] : []

    content {
      name                         = var.agents_pool_name
      vm_size                      = var.agents_size
      enable_auto_scaling          = var.enable_auto_scaling
      enable_host_encryption       = var.enable_host_encryption
      enable_node_public_ip        = var.enable_node_public_ip
      fips_enabled                 = var.default_node_pool_fips_enabled
      max_count                    = var.agents_max_count
      max_pods                     = var.agents_max_pods
      min_count                    = var.agents_min_count
      node_labels                  = var.agents_labels
      node_taints                  = var.agents_taints
      only_critical_addons_enabled = var.only_critical_addons_enabled
      orchestrator_version         = var.orchestrator_version
      os_disk_size_gb              = var.os_disk_size_gb
      os_disk_type                 = var.os_disk_type
      os_sku                       = var.os_sku
      pod_subnet_id                = var.pod_subnet_id
      proximity_placement_group_id = var.agents_proximity_placement_group_id
      scale_down_mode              = var.scale_down_mode
      snapshot_id                  = var.snapshot_id
      tags                         = merge(var.tags, var.agents_tags)
      temporary_name_for_rotation  = var.temporary_name_for_rotation
      type                         = var.agents_type
      ultra_ssd_enabled            = var.ultra_ssd_enabled
      vnet_subnet_id               = var.vnet_subnet_id
      zones                        = var.agents_availability_zones

      dynamic "kubelet_config" {
        for_each = var.agents_pool_kubelet_configs

        content {
          allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
          container_log_max_line    = kubelet_config.value.container_log_max_line
          container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
          cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
          cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
          cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
          image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
          image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
          pod_max_pid               = kubelet_config.value.pod_max_pid
          topology_manager_policy   = kubelet_config.value.topology_manager_policy
        }
      }
      dynamic "linux_os_config" {
        for_each = var.agents_pool_linux_os_configs

        content {
          swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
          transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
          transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled

          dynamic "sysctl_config" {
            for_each = linux_os_config.value.sysctl_configs == null ? [] : linux_os_config.value.sysctl_configs

            content {
              fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
              fs_file_max                        = sysctl_config.value.fs_file_max
              fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
              fs_nr_open                         = sysctl_config.value.fs_nr_open
              kernel_threads_max                 = sysctl_config.value.kernel_threads_max
              net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
              net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
              net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
              net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
              net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
              net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
              net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
              net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
              net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
              net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
              net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
              net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
              net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
              net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
              net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
              net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
              net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
              net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
              net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
              net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
              net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
              vm_max_map_count                   = sysctl_config.value.vm_max_map_count
              vm_swappiness                      = sysctl_config.value.vm_swappiness
              vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
            }
          }
        }
      }
      dynamic "upgrade_settings" {
        for_each = var.agents_pool_max_surge == null ? [] : ["upgrade_settings"]

        content {
          max_surge = var.agents_pool_max_surge
        }
      }
    }
  }
  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux_enabled ? ["aci_connector_linux"] : []

    content {
      subnet_name = var.aci_connector_linux_subnet_name
    }
  }
  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null || var.api_server_subnet_id != null ? [
      "api_server_access_profile"
    ] : []

    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
      subnet_id            = var.api_server_subnet_id
    }
  }
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile_enabled ? ["default_auto_scaler_profile"] : []

    content {
      balance_similar_node_groups      = var.auto_scaler_profile_balance_similar_node_groups
      empty_bulk_delete_max            = var.auto_scaler_profile_empty_bulk_delete_max
      expander                         = var.auto_scaler_profile_expander
      max_graceful_termination_sec     = var.auto_scaler_profile_max_graceful_termination_sec
      max_node_provisioning_time       = var.auto_scaler_profile_max_node_provisioning_time
      max_unready_nodes                = var.auto_scaler_profile_max_unready_nodes
      max_unready_percentage           = var.auto_scaler_profile_max_unready_percentage
      new_pod_scale_up_delay           = var.auto_scaler_profile_new_pod_scale_up_delay
      scale_down_delay_after_add       = var.auto_scaler_profile_scale_down_delay_after_add
      scale_down_delay_after_delete    = local.auto_scaler_profile_scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.auto_scaler_profile_scale_down_delay_after_failure
      scale_down_unneeded              = var.auto_scaler_profile_scale_down_unneeded
      scale_down_unready               = var.auto_scaler_profile_scale_down_unready
      scale_down_utilization_threshold = var.auto_scaler_profile_scale_down_utilization_threshold
      scan_interval                    = var.auto_scaler_profile_scan_interval
      skip_nodes_with_local_storage    = var.auto_scaler_profile_skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = var.auto_scaler_profile_skip_nodes_with_system_pods
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && var.rbac_aad && var.rbac_aad_managed ? ["rbac"] : []

    content {
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
      managed                = true
      tenant_id              = var.rbac_aad_tenant_id
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled && var.rbac_aad && !var.rbac_aad_managed ? ["rbac"] : []

    content {
      client_app_id     = var.rbac_aad_client_app_id
      managed           = false
      server_app_id     = var.rbac_aad_server_app_id
      server_app_secret = var.rbac_aad_server_app_secret
      tenant_id         = var.rbac_aad_tenant_id
    }
  }
  dynamic "confidential_computing" {
    for_each = var.confidential_computing == null ? [] : [var.confidential_computing]

    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }
  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config == null ? [] : ["http_proxy_config"]
    content {
      http_proxy  = coalesce(var.http_proxy_config.http_proxy, var.http_proxy_config.https_proxy)
      https_proxy = coalesce(var.http_proxy_config.https_proxy, var.http_proxy_config.http_proxy)
      no_proxy    = var.http_proxy_config.no_proxy
      trusted_ca  = var.http_proxy_config.trusted_ca
    }
  }
  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? ["identity"] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }
  dynamic "ingress_application_gateway" {
    for_each = local.ingress_application_gateway_enabled ? ["ingress_application_gateway"] : []

    content {
      gateway_id   = try(var.brown_field_application_gateway_for_ingress.id, null)
      gateway_name = try(var.green_field_application_gateway_for_ingress.name, null)
      subnet_cidr  = try(var.green_field_application_gateway_for_ingress.subnet_cidr, null)
      subnet_id    = try(var.green_field_application_gateway_for_ingress.subnet_id, null)
    }
  }
  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["key_management_service"] : []

    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? ["key_vault_secrets_provider"] : []

    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity == null ? [] : [var.kubelet_identity]
    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }
  dynamic "linux_profile" {
    for_each = var.admin_username == null ? [] : ["linux_profile"]

    content {
      admin_username = var.admin_username

      ssh_key {
        key_data = replace(coalesce(var.public_ssh_key, tls_private_key.ssh[0].public_key_openssh), "\n", "")
      }
    }
  }
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? ["maintenance_window"] : []

    content {
      dynamic "allowed" {
        for_each = var.maintenance_window.allowed

        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.maintenance_window.not_allowed

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade == null ? [] : [var.maintenance_window_auto_upgrade]
    content {
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      start_date   = maintenance_window_auto_upgrade.value.start_date
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      week_index   = maintenance_window_auto_upgrade.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed == null ? [] : maintenance_window_auto_upgrade.value.not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os == null ? [] : [var.maintenance_window_node_os]
    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed == null ? [] : maintenance_window_node_os.value.not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }
  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? ["microsoft_defender"] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }
  dynamic "monitor_metrics" {
    for_each = var.monitor_metrics != null ? ["monitor_metrics"] : []

    content {
      annotations_allowed = var.monitor_metrics.annotations_allowed
      labels_allowed      = var.monitor_metrics.labels_allowed
    }
  }
  network_profile {
    network_plugin      = var.network_plugin
    dns_service_ip      = var.net_profile_dns_service_ip
    ebpf_data_plane     = var.ebpf_data_plane
    load_balancer_sku   = var.load_balancer_sku
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    outbound_type       = var.net_profile_outbound_type
    pod_cidr            = var.net_profile_pod_cidr
    service_cidr        = var.net_profile_service_cidr

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_profile_enabled && var.load_balancer_sku == "standard" ? [
        "load_balancer_profile"
      ] : []

      content {
        idle_timeout_in_minutes     = var.load_balancer_profile_idle_timeout_in_minutes
        managed_outbound_ip_count   = var.load_balancer_profile_managed_outbound_ip_count
        managed_outbound_ipv6_count = var.load_balancer_profile_managed_outbound_ipv6_count
        outbound_ip_address_ids     = var.load_balancer_profile_outbound_ip_address_ids
        outbound_ip_prefix_ids      = var.load_balancer_profile_outbound_ip_prefix_ids
        outbound_ports_allocated    = var.load_balancer_profile_outbound_ports_allocated
      }
    }
  }
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_enabled ? ["oms_agent"] : []

    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = var.msi_auth_for_monitoring_enabled
    }
  }
  dynamic "service_mesh_profile" {
    for_each = var.service_mesh_profile == null ? [] : ["service_mesh_profile"]
    content {
      mode                             = var.service_mesh_profile.mode
      external_ingress_gateway_enabled = var.service_mesh_profile.external_ingress_gateway_enabled
      internal_ingress_gateway_enabled = var.service_mesh_profile.internal_ingress_gateway_enabled
    }
  }
  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []

    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }
  dynamic "storage_profile" {
    for_each = var.storage_profile_enabled ? ["storage_profile"] : []

    content {
      blob_driver_enabled         = var.storage_profile_blob_driver_enabled
      disk_driver_enabled         = var.storage_profile_disk_driver_enabled
      disk_driver_version         = var.storage_profile_disk_driver_version
      file_driver_enabled         = var.storage_profile_file_driver_enabled
      snapshot_controller_enabled = var.storage_profile_snapshot_controller_enabled
    }
  }
  dynamic "web_app_routing" {
    for_each = var.web_app_routing == null ? [] : ["web_app_routing"]

    content {
      dns_zone_id = var.web_app_routing.dns_zone_id
    }
  }
  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile == null ? [] : [var.workload_autoscaler_profile]

    content {
      keda_enabled                    = workload_autoscaler_profile.value.keda_enabled
      vertical_pod_autoscaler_enabled = workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled
    }
  }

  lifecycle {
    ignore_changes = [
      http_application_routing_enabled,
      http_proxy_config[0].no_proxy,
      kubernetes_version,
      # we might have a random suffix in cluster's name so we have to ignore it here, but we've traced user supplied cluster name by `null_resource.kubernetes_cluster_name_keeper` so when the name is changed we'll recreate this resource.
      name,
    ]
    replace_triggered_by = [
      null_resource.kubernetes_cluster_name_keeper.id
    ]

    precondition {
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type != "")
      error_message = "Either `client_id` and `client_secret` or `identity_type` must be set."
    }
    precondition {
      # Why don't use var.identity_ids != null && length(var.identity_ids)>0 ? Because bool expression in Terraform is not short circuit so even var.identity_ids is null Terraform will still invoke length function with null and cause error. https://github.com/hashicorp/terraform/issues/24128
      condition     = (var.client_id != "" && var.client_secret != "") || (var.identity_type == "SystemAssigned") || (var.identity_ids == null ? false : length(var.identity_ids) > 0)
      error_message = "If use identity and `UserAssigned` is set, an `identity_ids` must be set as well."
    }
    precondition {
      condition     = !(var.microsoft_defender_enabled && !var.log_analytics_workspace_enabled)
      error_message = "Enabling Microsoft Defender requires that `log_analytics_workspace_enabled` be set to true."
    }
    precondition {
      condition     = !(var.load_balancer_profile_enabled && var.load_balancer_sku != "standard")
      error_message = "Enabling load_balancer_profile requires that `load_balancer_sku` be set to `standard`"
    }
    precondition {
      condition     = local.automatic_channel_upgrade_check
      error_message = "Either disable automatic upgrades, or specify `kubernetes_version` or `orchestrator_version` only up to the minor version when using `automatic_channel_upgrade=patch`. You don't need to specify `kubernetes_version` at all when using `automatic_channel_upgrade=stable|rapid|node-image`, where `orchestrator_version` always must be set to `null`."
    }
    precondition {
      condition     = var.role_based_access_control_enabled || !var.rbac_aad
      error_message = "Enabling Azure Active Directory integration requires that `role_based_access_control_enabled` be set to true."
    }
    precondition {
      condition     = !(var.kms_enabled && var.identity_type != "UserAssigned")
      error_message = "KMS etcd encryption doesn't work with system-assigned managed identity."
    }
    precondition {
      condition     = !var.workload_identity_enabled || var.oidc_issuer_enabled
      error_message = "`oidc_issuer_enabled` must be set to `true` to enable Azure AD Workload Identity"
    }
    precondition {
      condition     = var.network_plugin_mode != "overlay" || var.network_plugin == "azure"
      error_message = "When network_plugin_mode is set to `overlay`, the network_plugin field can only be set to azure."
    }
    precondition {
      condition     = var.ebpf_data_plane != "cilium" || var.network_plugin == "azure"
      error_message = "When ebpf_data_plane is set to cilium, the network_plugin field can only be set to azure."
    }
    precondition {
      condition     = var.ebpf_data_plane != "cilium" || var.network_plugin_mode == "overlay" || var.pod_subnet_id != null
      error_message = "When ebpf_data_plane is set to cilium, one of either network_plugin_mode = `overlay` or pod_subnet_id must be specified."
    }
    precondition {
      condition     = can(coalesce(var.cluster_name, var.prefix))
      error_message = "You must set one of `var.cluster_name` and `var.prefix` to create `azurerm_kubernetes_cluster.aks`."
    }
    precondition {
      condition     = var.automatic_channel_upgrade != "node-image" || var.node_os_channel_upgrade == "NodeImage"
      error_message = "`node_os_channel_upgrade` must be set to `NodeImage` if `automatic_channel_upgrade` has been set to `node-image`."
    }
    precondition {
      condition = (var.kubelet_identity == null) || (
      (var.client_id == "" || var.client_secret == "") && var.identity_type == "UserAssigned" && try(length(var.identity_ids), 0) > 0)
      error_message = "When `kubelet_identity` is enabled - The `type` field in the `identity` block must be set to `UserAssigned` and `identity_ids` must be set."
    }
    precondition {
      condition     = var.enable_auto_scaling != true || var.agents_type == "VirtualMachineScaleSets"
      error_message = "Autoscaling on default node pools is only supported when the Kubernetes Cluster is using Virtual Machine Scale Sets type nodes."
    }
    precondition {
      condition     = var.brown_field_application_gateway_for_ingress == null || var.green_field_application_gateway_for_ingress == null
      error_message = "Either one of `var.brown_field_application_gateway_for_ingress` or `var.green_field_application_gateway_for_ingress` must be `null`."
    }
  }
}

resource "null_resource" "kubernetes_cluster_name_keeper" {
  triggers = {
    name = local.cluster_name
  }
}

resource "null_resource" "kubernetes_version_keeper" {
  triggers = {
    version = var.kubernetes_version
  }
}

// resource "azapi_update_resource" "aks_cluster_post_create" {
//   type = "Microsoft.ContainerService/managedClusters@2023-01-02-preview"
//   body = jsonencode({
//     properties = {
//       kubernetesVersion = var.kubernetes_version
//     }
//   })
//   resource_id = azurerm_kubernetes_cluster.aks.id

//   lifecycle {
//     ignore_changes       = all
//     replace_triggered_by = [null_resource.kubernetes_version_keeper.id]
//   }
// }

resource "null_resource" "http_proxy_config_no_proxy_keeper" {
  count = can(var.http_proxy_config.no_proxy[0]) ? 1 : 0

  triggers = {
    http_proxy_no_proxy = try(join(",", try(sort(var.http_proxy_config.no_proxy), [])), "")
  }
}

// # Allow user assigned identity to manage AKS items in Node RG
// resource "azurerm_role_assignment" "aks_user_assigned" {
//   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
//   scope                = format("/subscriptions/%s/resourceGroups/%s", data.azurerm_subscription.current.subscription_id, azurerm_kubernetes_cluster.aks.node_resource_group)
//   role_definition_name = "Contributor"
// }

// resource "azurerm_role_assignment" "aks_acr_pull_allowed" {
//   for_each = toset(var.container_registries_id)

//   #principal_id         = azurerm_user_assigned_identity.aks_user_assigned_identity.principal_id
//   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
//   scope                = each.value
//   role_definition_name = "AcrPull"
// }

// resource "azurerm_role_assignment" "aks_kubelet_uai_vnet_network_contributor" {
//   scope                = var.vnet_id
//   role_definition_name = "Network Contributor"
//   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
// }

// resource "azapi_update_resource" "aks_cluster_http_proxy_config_no_proxy" {
//   count = can(var.http_proxy_config.no_proxy[0]) ? 1 : 0

//   type = "Microsoft.ContainerService/managedClusters@2023-01-02-preview"
//   body = jsonencode({
//     properties = {
//       httpProxyConfig = {
//         noProxy = var.http_proxy_config.no_proxy
//       }
//     }
//   })
//   resource_id = azurerm_kubernetes_cluster.aks.id

//   depends_on = [azapi_update_resource.aks_cluster_post_create]

//   lifecycle {
//     ignore_changes       = all
//     replace_triggered_by = [null_resource.http_proxy_config_no_proxy_keeper[0].id]
//   }
// }
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aci_connector_linux_enabled"></a> [aci\_connector\_linux\_enabled](#input\_aci\_connector\_linux\_enabled) | Enable Virtual Node pool | `bool` | `false` | no |
| <a name="input_aci_connector_linux_subnet_name"></a> [aci\_connector\_linux\_subnet\_name](#input\_aci\_connector\_linux\_subnet\_name) | (Optional) aci\_connector\_linux subnet name | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username of the local administrator to be created on the Kubernetes cluster. Set this variable to `null` to turn off the cluster's `linux_profile`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_agents_availability_zones"></a> [agents\_availability\_zones](#input\_agents\_availability\_zones) | (Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created. | `list(string)` | `null` | no |
| <a name="input_agents_count"></a> [agents\_count](#input\_agents\_count) | The number of Agents that should exist in the Agent Pool. Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes. | `number` | `2` | no |
| <a name="input_agents_labels"></a> [agents\_labels](#input\_agents\_labels) | (Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created. | `map(string)` | `{}` | no |
| <a name="input_agents_max_count"></a> [agents\_max\_count](#input\_agents\_max\_count) | Maximum number of nodes in a pool | `number` | `null` | no |
| <a name="input_agents_max_pods"></a> [agents\_max\_pods](#input\_agents\_max\_pods) | (Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. | `number` | `null` | no |
| <a name="input_agents_min_count"></a> [agents\_min\_count](#input\_agents\_min\_count) | Minimum number of nodes in a pool | `number` | `null` | no |
| <a name="input_agents_pool_kubelet_configs"></a> [agents\_pool\_kubelet\_configs](#input\_agents\_pool\_kubelet\_configs) | list(object({<br>    cpu\_manager\_policy        = (Optional) Specifies the CPU Manager policy to use. Possible values are `none` and `static`, Changing this forces a new resource to be created.<br>    cpu\_cfs\_quota\_enabled     = (Optional) Is CPU CFS quota enforcement for containers enabled? Changing this forces a new resource to be created.<br>    cpu\_cfs\_quota\_period      = (Optional) Specifies the CPU CFS quota period value. Changing this forces a new resource to be created.<br>    image\_gc\_high\_threshold   = (Optional) Specifies the percent of disk usage above which image garbage collection is always run. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    image\_gc\_low\_threshold    = (Optional) Specifies the percent of disk usage lower than which image garbage collection is never run. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    topology\_manager\_policy   = (Optional) Specifies the Topology Manager policy to use. Possible values are `none`, `best-effort`, `restricted` or `single-numa-node`. Changing this forces a new resource to be created.<br>    allowed\_unsafe\_sysctls    = (Optional) Specifies the allow list of unsafe sysctls command or patterns (ending in `*`). Changing this forces a new resource to be created.<br>    container\_log\_max\_size\_mb = (Optional) Specifies the maximum size (e.g. 10MB) of container log file before it is rotated. Changing this forces a new resource to be created.<br>    container\_log\_max\_line    = (Optional) Specifies the maximum number of container log files that can be present for a container. must be at least 2. Changing this forces a new resource to be created.<br>    pod\_max\_pid               = (Optional) Specifies the maximum number of processes per pod. Changing this forces a new resource to be created.<br>})) | <pre>list(object({<br>    cpu_manager_policy        = optional(string)<br>    cpu_cfs_quota_enabled     = optional(bool, true)<br>    cpu_cfs_quota_period      = optional(string)<br>    image_gc_high_threshold   = optional(number)<br>    image_gc_low_threshold    = optional(number)<br>    topology_manager_policy   = optional(string)<br>    allowed_unsafe_sysctls    = optional(set(string))<br>    container_log_max_size_mb = optional(number)<br>    container_log_max_line    = optional(number)<br>    pod_max_pid               = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_agents_pool_linux_os_configs"></a> [agents\_pool\_linux\_os\_configs](#input\_agents\_pool\_linux\_os\_configs) | list(object({<br>  sysctl\_configs = optional(list(object({<br>    fs\_aio\_max\_nr                      = (Optional) The sysctl setting fs.aio-max-nr. Must be between `65536` and `6553500`. Changing this forces a new resource to be created.<br>    fs\_file\_max                        = (Optional) The sysctl setting fs.file-max. Must be between `8192` and `12000500`. Changing this forces a new resource to be created.<br>    fs\_inotify\_max\_user\_watches        = (Optional) The sysctl setting fs.inotify.max\_user\_watches. Must be between `781250` and `2097152`. Changing this forces a new resource to be created.<br>    fs\_nr\_open                         = (Optional) The sysctl setting fs.nr\_open. Must be between `8192` and `20000500`. Changing this forces a new resource to be created.<br>    kernel\_threads\_max                 = (Optional) The sysctl setting kernel.threads-max. Must be between `20` and `513785`. Changing this forces a new resource to be created.<br>    net\_core\_netdev\_max\_backlog        = (Optional) The sysctl setting net.core.netdev\_max\_backlog. Must be between `1000` and `3240000`. Changing this forces a new resource to be created.<br>    net\_core\_optmem\_max                = (Optional) The sysctl setting net.core.optmem\_max. Must be between `20480` and `4194304`. Changing this forces a new resource to be created.<br>    net\_core\_rmem\_default              = (Optional) The sysctl setting net.core.rmem\_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>    net\_core\_rmem\_max                  = (Optional) The sysctl setting net.core.rmem\_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>    net\_core\_somaxconn                 = (Optional) The sysctl setting net.core.somaxconn. Must be between `4096` and `3240000`. Changing this forces a new resource to be created.<br>    net\_core\_wmem\_default              = (Optional) The sysctl setting net.core.wmem\_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>    net\_core\_wmem\_max                  = (Optional) The sysctl setting net.core.wmem\_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>    net\_ipv4\_ip\_local\_port\_range\_min   = (Optional) The sysctl setting net.ipv4.ip\_local\_port\_range max value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.<br>    net\_ipv4\_ip\_local\_port\_range\_max   = (Optional) The sysctl setting net.ipv4.ip\_local\_port\_range min value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.<br>    net\_ipv4\_neigh\_default\_gc\_thresh1  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh1. Must be between `128` and `80000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_neigh\_default\_gc\_thresh2  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh2. Must be between `512` and `90000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_neigh\_default\_gc\_thresh3  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh3. Must be between `1024` and `100000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_fin\_timeout           = (Optional) The sysctl setting net.ipv4.tcp\_fin\_timeout. Must be between `5` and `120`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_keepalive\_intvl       = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_intvl. Must be between `10` and `75`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_keepalive\_probes      = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_probes. Must be between `1` and `15`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_keepalive\_time        = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_time. Must be between `30` and `432000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_max\_syn\_backlog       = (Optional) The sysctl setting net.ipv4.tcp\_max\_syn\_backlog. Must be between `128` and `3240000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_max\_tw\_buckets        = (Optional) The sysctl setting net.ipv4.tcp\_max\_tw\_buckets. Must be between `8000` and `1440000`. Changing this forces a new resource to be created.<br>    net\_ipv4\_tcp\_tw\_reuse              = (Optional) The sysctl setting net.ipv4.tcp\_tw\_reuse. Changing this forces a new resource to be created.<br>    net\_netfilter\_nf\_conntrack\_buckets = (Optional) The sysctl setting net.netfilter.nf\_conntrack\_buckets. Must be between `65536` and `147456`. Changing this forces a new resource to be created.<br>    net\_netfilter\_nf\_conntrack\_max     = (Optional) The sysctl setting net.netfilter.nf\_conntrack\_max. Must be between `131072` and `1048576`. Changing this forces a new resource to be created.<br>    vm\_max\_map\_count                   = (Optional) The sysctl setting vm.max\_map\_count. Must be between `65530` and `262144`. Changing this forces a new resource to be created.<br>    vm\_swappiness                      = (Optional) The sysctl setting vm.swappiness. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    vm\_vfs\_cache\_pressure              = (Optional) The sysctl setting vm.vfs\_cache\_pressure. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>  })), [])<br>  transparent\_huge\_page\_enabled = (Optional) Specifies the Transparent Huge Page enabled configuration. Possible values are `always`, `madvise` and `never`. Changing this forces a new resource to be created.<br>  transparent\_huge\_page\_defrag  = (Optional) specifies the defrag configuration for Transparent Huge Page. Possible values are `always`, `defer`, `defer+madvise`, `madvise` and `never`. Changing this forces a new resource to be created.<br>  swap\_file\_size\_mb             = (Optional) Specifies the size of the swap file on each node in MB. Changing this forces a new resource to be created.<br>})) | <pre>list(object({<br>    sysctl_configs = optional(list(object({<br>      fs_aio_max_nr                      = optional(number)<br>      fs_file_max                        = optional(number)<br>      fs_inotify_max_user_watches        = optional(number)<br>      fs_nr_open                         = optional(number)<br>      kernel_threads_max                 = optional(number)<br>      net_core_netdev_max_backlog        = optional(number)<br>      net_core_optmem_max                = optional(number)<br>      net_core_rmem_default              = optional(number)<br>      net_core_rmem_max                  = optional(number)<br>      net_core_somaxconn                 = optional(number)<br>      net_core_wmem_default              = optional(number)<br>      net_core_wmem_max                  = optional(number)<br>      net_ipv4_ip_local_port_range_min   = optional(number)<br>      net_ipv4_ip_local_port_range_max   = optional(number)<br>      net_ipv4_neigh_default_gc_thresh1  = optional(number)<br>      net_ipv4_neigh_default_gc_thresh2  = optional(number)<br>      net_ipv4_neigh_default_gc_thresh3  = optional(number)<br>      net_ipv4_tcp_fin_timeout           = optional(number)<br>      net_ipv4_tcp_keepalive_intvl       = optional(number)<br>      net_ipv4_tcp_keepalive_probes      = optional(number)<br>      net_ipv4_tcp_keepalive_time        = optional(number)<br>      net_ipv4_tcp_max_syn_backlog       = optional(number)<br>      net_ipv4_tcp_max_tw_buckets        = optional(number)<br>      net_ipv4_tcp_tw_reuse              = optional(bool)<br>      net_netfilter_nf_conntrack_buckets = optional(number)<br>      net_netfilter_nf_conntrack_max     = optional(number)<br>      vm_max_map_count                   = optional(number)<br>      vm_swappiness                      = optional(number)<br>      vm_vfs_cache_pressure              = optional(number)<br>    })), [])<br>    transparent_huge_page_enabled = optional(string)<br>    transparent_huge_page_defrag  = optional(string)<br>    swap_file_size_mb             = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_agents_pool_max_surge"></a> [agents\_pool\_max\_surge](#input\_agents\_pool\_max\_surge) | The maximum number or percentage of nodes which will be added to the Default Node Pool size during an upgrade. | `string` | `null` | no |
| <a name="input_agents_pool_name"></a> [agents\_pool\_name](#input\_agents\_pool\_name) | The default Azure AKS agentpool (nodepool) name. | `string` | `"nodepool"` | no |
| <a name="input_agents_proximity_placement_group_id"></a> [agents\_proximity\_placement\_group\_id](#input\_agents\_proximity\_placement\_group\_id) | (Optional) The ID of the Proximity Placement Group of the default Azure AKS agentpool (nodepool). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The default virtual machine size for the Kubernetes agents. Changing this without specifying `var.temporary_name_for_rotation` forces a new resource to be created. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_agents_tags"></a> [agents\_tags](#input\_agents\_tags) | (Optional) A mapping of tags to assign to the Node Pool. | `map(string)` | `{}` | no |
| <a name="input_agents_taints"></a> [agents\_taints](#input\_agents\_taints) | (Optional) A list of the taints added to new nodes during node pool create and scale. Changing this forces a new resource to be created. | `list(string)` | `null` | no |
| <a name="input_agents_type"></a> [agents\_type](#input\_agents\_type) | (Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets. | `string` | `"VirtualMachineScaleSets"` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | (Optional) The IP ranges to allow for incoming traffic to the server nodes. | `set(string)` | `null` | no |
| <a name="input_api_server_subnet_id"></a> [api\_server\_subnet\_id](#input\_api\_server\_subnet\_id) | (Optional) The ID of the Subnet where the API server endpoint is delegated to. | `string` | `null` | no |
| <a name="input_attached_acr_id_map"></a> [attached\_acr\_id\_map](#input\_attached\_acr\_id\_map) | Azure Container Registry ids that need an authentication mechanism with Azure Kubernetes Service (AKS). Map key must be static string as acr's name, the value is acr's resource id. Changing this forces some new resources to be created. | `map(string)` | `{}` | no |
| <a name="input_auto_scaler_profile_balance_similar_node_groups"></a> [auto\_scaler\_profile\_balance\_similar\_node\_groups](#input\_auto\_scaler\_profile\_balance\_similar\_node\_groups) | Detect similar node groups and balance the number of nodes between them. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_empty_bulk_delete_max"></a> [auto\_scaler\_profile\_empty\_bulk\_delete\_max](#input\_auto\_scaler\_profile\_empty\_bulk\_delete\_max) | Maximum number of empty nodes that can be deleted at the same time. Defaults to `10`. | `number` | `10` | no |
| <a name="input_auto_scaler_profile_enabled"></a> [auto\_scaler\_profile\_enabled](#input\_auto\_scaler\_profile\_enabled) | Enable configuring the auto scaler profile | `bool` | `false` | no |
| <a name="input_auto_scaler_profile_expander"></a> [auto\_scaler\_profile\_expander](#input\_auto\_scaler\_profile\_expander) | Expander to use. Possible values are `least-waste`, `priority`, `most-pods` and `random`. Defaults to `random`. | `string` | `"random"` | no |
| <a name="input_auto_scaler_profile_max_graceful_termination_sec"></a> [auto\_scaler\_profile\_max\_graceful\_termination\_sec](#input\_auto\_scaler\_profile\_max\_graceful\_termination\_sec) | Maximum number of seconds the cluster autoscaler waits for pod termination when trying to scale down a node. Defaults to `600`. | `string` | `"600"` | no |
| <a name="input_auto_scaler_profile_max_node_provisioning_time"></a> [auto\_scaler\_profile\_max\_node\_provisioning\_time](#input\_auto\_scaler\_profile\_max\_node\_provisioning\_time) | Maximum time the autoscaler waits for a node to be provisioned. Defaults to `15m`. | `string` | `"15m"` | no |
| <a name="input_auto_scaler_profile_max_unready_nodes"></a> [auto\_scaler\_profile\_max\_unready\_nodes](#input\_auto\_scaler\_profile\_max\_unready\_nodes) | Maximum Number of allowed unready nodes. Defaults to `3`. | `number` | `3` | no |
| <a name="input_auto_scaler_profile_max_unready_percentage"></a> [auto\_scaler\_profile\_max\_unready\_percentage](#input\_auto\_scaler\_profile\_max\_unready\_percentage) | Maximum percentage of unready nodes the cluster autoscaler will stop if the percentage is exceeded. Defaults to `45`. | `number` | `45` | no |
| <a name="input_auto_scaler_profile_new_pod_scale_up_delay"></a> [auto\_scaler\_profile\_new\_pod\_scale\_up\_delay](#input\_auto\_scaler\_profile\_new\_pod\_scale\_up\_delay) | For scenarios like burst/batch scale where you don't want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they're a certain age. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_add"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_add](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_add) | How long after the scale up of AKS nodes the scale down evaluation resumes. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_delete"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_delete](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_delete) | How long after node deletion that scale down evaluation resumes. Defaults to the value used for `scan_interval`. | `string` | `null` | no |
| <a name="input_auto_scaler_profile_scale_down_delay_after_failure"></a> [auto\_scaler\_profile\_scale\_down\_delay\_after\_failure](#input\_auto\_scaler\_profile\_scale\_down\_delay\_after\_failure) | How long after scale down failure that scale down evaluation resumes. Defaults to `3m`. | `string` | `"3m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unneeded"></a> [auto\_scaler\_profile\_scale\_down\_unneeded](#input\_auto\_scaler\_profile\_scale\_down\_unneeded) | How long a node should be unneeded before it is eligible for scale down. Defaults to `10m`. | `string` | `"10m"` | no |
| <a name="input_auto_scaler_profile_scale_down_unready"></a> [auto\_scaler\_profile\_scale\_down\_unready](#input\_auto\_scaler\_profile\_scale\_down\_unready) | How long an unready node should be unneeded before it is eligible for scale down. Defaults to `20m`. | `string` | `"20m"` | no |
| <a name="input_auto_scaler_profile_scale_down_utilization_threshold"></a> [auto\_scaler\_profile\_scale\_down\_utilization\_threshold](#input\_auto\_scaler\_profile\_scale\_down\_utilization\_threshold) | Node utilization level, defined as sum of requested resources divided by capacity, below which a node can be considered for scale down. Defaults to `0.5`. | `string` | `"0.5"` | no |
| <a name="input_auto_scaler_profile_scan_interval"></a> [auto\_scaler\_profile\_scan\_interval](#input\_auto\_scaler\_profile\_scan\_interval) | How often the AKS Cluster should be re-evaluated for scale up/down. Defaults to `10s`. | `string` | `"10s"` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_local_storage"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_local\_storage) | If `true` cluster autoscaler will never delete nodes with pods with local storage, for example, EmptyDir or HostPath. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_auto_scaler_profile_skip_nodes_with_system_pods"></a> [auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods](#input\_auto\_scaler\_profile\_skip\_nodes\_with\_system\_pods) | If `true` cluster autoscaler will never delete nodes with pods from kube-system (except for DaemonSet or mirror pods). Defaults to `true`. | `bool` | `true` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`. By default automatic-upgrades are turned off. Note that you cannot specify the patch version using `kubernetes_version` or `orchestrator_version` when using the `patch` upgrade channel. See [the documentation](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster) for more information | `string` | `null` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable Azure Policy Addon. | `bool` | `false` | no |
| <a name="input_brown_field_application_gateway_for_ingress"></a> [brown\_field\_application\_gateway\_for\_ingress](#input\_brown\_field\_application\_gateway\_for\_ingress) | [Definition of `brown_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)<br>* `id` - (Required) The ID of the Application Gateway that be used as cluster ingress.<br>* `subnet_id` - (Required) The ID of the Subnet which the Application Gateway is connected to. Must be set when `create_role_assignments` is `true`. | <pre>object({<br>    id        = string<br>    subnet_id = string<br>  })</pre> | `null` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | (Optional) The Client ID (appId) for the Service Principal used for the AKS deployment | `string` | `""` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | (Optional) The Client Secret (password) for the Service Principal used for the AKS deployment | `string` | `""` | no |
| <a name="input_cluster_log_analytics_workspace_name"></a> [cluster\_log\_analytics\_workspace\_name](#input\_cluster\_log\_analytics\_workspace\_name) | (Optional) The name of the Analytics workspace | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Optional) The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns\_prefix if it is set) | `string` | `null` | no |
| <a name="input_cluster_name_random_suffix"></a> [cluster\_name\_random\_suffix](#input\_cluster\_name\_random\_suffix) | Whether to add a random suffix on Aks cluster's name or not. `azurerm_kubernetes_cluster` resource defined in this module is `create_before_destroy = true` implicity now(described [here](https://github.com/Azure/terraform-azurerm-aks/issues/389)), without this random suffix we'll not be able to recreate this cluster directly due to the naming conflict. | `bool` | `false` | no |
| <a name="input_confidential_computing"></a> [confidential\_computing](#input\_confidential\_computing) | (Optional) Enable Confidential Computing. | <pre>object({<br>    sgx_quote_helper_enabled = bool<br>  })</pre> | `null` | no |
| <a name="input_create_role_assignment_network_contributor"></a> [create\_role\_assignment\_network\_contributor](#input\_create\_role\_assignment\_network\_contributor) | (Deprecated) Create a role assignment for the AKS Service Principal to be a Network Contributor on the subnets used for the AKS Cluster | `bool` | `false` | no |
| <a name="input_create_role_assignments_for_application_gateway"></a> [create\_role\_assignments\_for\_application\_gateway](#input\_create\_role\_assignments\_for\_application\_gateway) | (Optional) Whether to create the corresponding role assignments for application gateway or not. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_default_node_pool_fips_enabled"></a> [default\_node\_pool\_fips\_enabled](#input\_default\_node\_pool\_fips\_enabled) | (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | (Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. More information [can be found in the documentation](https://docs.microsoft.com/azure/aks/azure-disk-customer-managed-keys). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_ebpf_data_plane"></a> [ebpf\_data\_plane](#input\_ebpf\_data\_plane) | (Optional) Specifies the eBPF data plane used for building the Kubernetes network. Possible value is `cilium`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable node pool autoscaling | `bool` | `false` | no |
| <a name="input_enable_host_encryption"></a> [enable\_host\_encryption](#input\_enable\_host\_encryption) | Enable Host Encryption for default node pool. Encryption at host feature must be enabled on the subscription: https://docs.microsoft.com/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli | `bool` | `false` | no |
| <a name="input_enable_node_public_ip"></a> [enable\_node\_public\_ip](#input\_enable\_node\_public\_ip) | (Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false. | `bool` | `false` | no |
| <a name="input_green_field_application_gateway_for_ingress"></a> [green\_field\_application\_gateway\_for\_ingress](#input\_green\_field\_application\_gateway\_for\_ingress) | [Definition of `green_field`](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)<br>* `name` - (Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br>* `subnet_cidr` - (Optional) The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster.<br>* `subnet_id` - (Optional) The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster. | <pre>object({<br>    name        = optional(string)<br>    subnet_cidr = optional(string)<br>    subnet_id   = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | optional(object({<br>    http\_proxy  = (Optional) The proxy address to be used when communicating over HTTP.<br>    https\_proxy = (Optional) The proxy address to be used when communicating over HTTPS.<br>    no\_proxy    = (Optional) The list of domains that will not use the proxy for communication. Note: If you specify the `default_node_pool.0.vnet_subnet_id`, be sure to include the Subnet CIDR in the `no_proxy` list. Note: You may wish to use Terraform's `ignore_changes` functionality to ignore the changes to this field.<br>    trusted\_ca  = (Optional) The base64 encoded alternative CA certificate content in PEM format.<br>}))<br>Once you have set only one of `http_proxy` and `https_proxy`, this config would be used for both `http_proxy` and `https_proxy` to avoid a configuration drift. | <pre>object({<br>    http_proxy  = optional(string)<br>    https_proxy = optional(string)<br>    no_proxy    = optional(list(string))<br>    trusted_ca  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Kubernetes Cluster. | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | (Optional) The type of identity used for the managed cluster. Conflicts with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, an `identity_ids` must be set as well. | `string` | `"SystemAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | (Optional) Specifies whether Image Cleaner is enabled. | `bool` | `false` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | (Optional) Specifies the interval in hours when images should be cleaned up. Defaults to `48`. | `number` | `48` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | (Optional) Whether to use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster. For more details: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver | `bool` | `false` | no |
| <a name="input_kms_enabled"></a> [kms\_enabled](#input\_kms\_enabled) | (Optional) Enable Azure KeyVault Key Management Service. | `bool` | `false` | no |
| <a name="input_kms_key_vault_key_id"></a> [kms\_key\_vault\_key\_id](#input\_kms\_key\_vault\_key\_id) | (Optional) Identifier of Azure Key Vault key. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier. | `string` | `null` | no |
| <a name="input_kms_key_vault_network_access"></a> [kms\_key\_vault\_network\_access](#input\_kms\_key\_vault\_network\_access) | (Optional) Network Access of Azure Key Vault. Possible values are: `Private` and `Public`. | `string` | `"Public"` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | - `client_id` - (Optional) The Client ID of the user-defined Managed Identity to be assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.<br>- `object_id` - (Optional) The Object ID of the user-defined Managed Identity assigned to the Kubelets.If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created.<br>- `user_assigned_identity_id` - (Optional) The ID of the User Assigned Identity assigned to the Kubelets. If not specified a Managed Identity is created automatically. Changing this forces a new resource to be created. | <pre>object({<br>    client_id                 = optional(string)<br>    object_id                 = optional(string)<br>    user_assigned_identity_id = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_load_balancer_profile_enabled"></a> [load\_balancer\_profile\_enabled](#input\_load\_balancer\_profile\_enabled) | (Optional) Enable a load\_balancer\_profile block. This can only be used when load\_balancer\_sku is set to `standard`. | `bool` | `false` | no |
| <a name="input_load_balancer_profile_idle_timeout_in_minutes"></a> [load\_balancer\_profile\_idle\_timeout\_in\_minutes](#input\_load\_balancer\_profile\_idle\_timeout\_in\_minutes) | (Optional) Desired outbound flow idle timeout in minutes for the cluster load balancer. Must be between `4` and `120` inclusive. | `number` | `30` | no |
| <a name="input_load_balancer_profile_managed_outbound_ip_count"></a> [load\_balancer\_profile\_managed\_outbound\_ip\_count](#input\_load\_balancer\_profile\_managed\_outbound\_ip\_count) | (Optional) Count of desired managed outbound IPs for the cluster load balancer. Must be between `1` and `100` inclusive | `number` | `null` | no |
| <a name="input_load_balancer_profile_managed_outbound_ipv6_count"></a> [load\_balancer\_profile\_managed\_outbound\_ipv6\_count](#input\_load\_balancer\_profile\_managed\_outbound\_ipv6\_count) | (Optional) The desired number of IPv6 outbound IPs created and managed by Azure for the cluster load balancer. Must be in the range of `1` to `100` (inclusive). The default value is `0` for single-stack and `1` for dual-stack. Note: managed\_outbound\_ipv6\_count requires dual-stack networking. To enable dual-stack networking the Preview Feature Microsoft.ContainerService/AKS-EnableDualStack needs to be enabled and the Resource Provider re-registered, see the documentation for more information. https://learn.microsoft.com/en-us/azure/aks/configure-kubenet-dual-stack?tabs=azure-cli%2Ckubectl#register-the-aks-enabledualstack-preview-feature | `number` | `null` | no |
| <a name="input_load_balancer_profile_outbound_ip_address_ids"></a> [load\_balancer\_profile\_outbound\_ip\_address\_ids](#input\_load\_balancer\_profile\_outbound\_ip\_address\_ids) | (Optional) The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer. | `set(string)` | `null` | no |
| <a name="input_load_balancer_profile_outbound_ip_prefix_ids"></a> [load\_balancer\_profile\_outbound\_ip\_prefix\_ids](#input\_load\_balancer\_profile\_outbound\_ip\_prefix\_ids) | (Optional) The ID of the outbound Public IP Address Prefixes which should be used for the cluster load balancer. | `set(string)` | `null` | no |
| <a name="input_load_balancer_profile_outbound_ports_allocated"></a> [load\_balancer\_profile\_outbound\_ports\_allocated](#input\_load\_balancer\_profile\_outbound\_ports\_allocated) | (Optional) Number of desired SNAT port for each VM in the clusters load balancer. Must be between `0` and `64000` inclusive. Defaults to `0` | `number` | `0` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | (Optional) Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are `basic` and `standard`. Defaults to `standard`. Changing this forces a new kubernetes cluster to be created. | `string` | `"standard"` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | (Optional) - If `true` local accounts will be disabled. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts) for more information. | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Location of cluster, if not defined it will be read from the resource-group | `string` | `null` | no |
| <a name="input_log_analytics_solution"></a> [log\_analytics\_solution](#input\_log\_analytics\_solution) | (Optional) Object which contains existing azurerm\_log\_analytics\_solution ID. Providing ID disables creation of azurerm\_log\_analytics\_solution. | <pre>object({<br>    id = string<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace"></a> [log\_analytics\_workspace](#input\_log\_analytics\_workspace) | (Optional) Existing azurerm\_log\_analytics\_workspace to attach azurerm\_log\_analytics\_solution. Providing the config disables creation of azurerm\_log\_analytics\_workspace. | <pre>object({<br>    id                  = string<br>    name                = string<br>    location            = optional(string)<br>    resource_group_name = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_log_analytics_workspace_enabled"></a> [log\_analytics\_workspace\_enabled](#input\_log\_analytics\_workspace\_enabled) | Enable the integration of azurerm\_log\_analytics\_workspace and azurerm\_log\_analytics\_solution: https://docs.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-onboard | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Optional) Resource ID of LAW. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_resource_group_name"></a> [log\_analytics\_workspace\_resource\_group\_name](#input\_log\_analytics\_workspace\_resource\_group\_name) | (Optional) Resource group name to create azurerm\_log\_analytics\_solution. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018 | `string` | `"PerGB2018"` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | The retention period for the logs in days | `number` | `30` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance configuration of the managed cluster. | <pre>object({<br>    allowed = optional(list(object({<br>      day   = string<br>      hours = set(number)<br>      })), [<br>    ]),<br>    not_allowed = optional(list(object({<br>      end   = string<br>      start = string<br>    })), []),<br>  })</pre> | `null` | no |
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | - `day_of_month` - (Optional) The day of the month for the maintenance run. Required in combination with RelativeMonthly frequency. Value between 0 and 31 (inclusive).<br>- `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.<br>- `duration` - (Required) The duration of the window for maintenance to run in hours.<br>- `frequency` - (Required) Frequency of maintenance. Possible options are `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.<br>- `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.<br>- `start_date` - (Optional) The date on which the maintenance window begins to take effect.<br>- `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.<br>- `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.<br>- `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.<br><br>---<br>`not_allowed` block supports the following:<br>- `end` - (Required) The end of a time span, formatted as an RFC3339 string.<br>- `start` - (Required) The start of a time span, formatted as an RFC3339 string. | <pre>object({<br>    day_of_month = optional(number)<br>    day_of_week  = optional(string)<br>    duration     = number<br>    frequency    = string<br>    interval     = number<br>    start_date   = optional(string)<br>    start_time   = optional(string)<br>    utc_offset   = optional(string)<br>    week_index   = optional(string)<br>    not_allowed = optional(set(object({<br>      end   = string<br>      start = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | - `day_of_month` -<br>- `day_of_week` - (Optional) The day of the week for the maintenance run. Options are `Monday`, `Tuesday`, `Wednesday`, `Thurday`, `Friday`, `Saturday` and `Sunday`. Required in combination with weekly frequency.<br>- `duration` - (Required) The duration of the window for maintenance to run in hours.<br>- `frequency` - (Required) Frequency of maintenance. Possible options are `Daily`, `Weekly`, `AbsoluteMonthly` and `RelativeMonthly`.<br>- `interval` - (Required) The interval for maintenance runs. Depending on the frequency this interval is week or month based.<br>- `start_date` - (Optional) The date on which the maintenance window begins to take effect.<br>- `start_time` - (Optional) The time for maintenance to begin, based on the timezone determined by `utc_offset`. Format is `HH:mm`.<br>- `utc_offset` - (Optional) Used to determine the timezone for cluster maintenance.<br>- `week_index` - (Optional) The week in the month used for the maintenance run. Options are `First`, `Second`, `Third`, `Fourth`, and `Last`.<br><br>---<br>`not_allowed` block supports the following:<br>- `end` - (Required) The end of a time span, formatted as an RFC3339 string.<br>- `start` - (Required) The start of a time span, formatted as an RFC3339 string. | <pre>object({<br>    day_of_month = optional(number)<br>    day_of_week  = optional(string)<br>    duration     = number<br>    frequency    = string<br>    interval     = number<br>    start_date   = optional(string)<br>    start_time   = optional(string)<br>    utc_offset   = optional(string)<br>    week_index   = optional(string)<br>    not_allowed = optional(set(object({<br>      end   = string<br>      start = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_microsoft_defender_enabled"></a> [microsoft\_defender\_enabled](#input\_microsoft\_defender\_enabled) | (Optional) Is Microsoft Defender on the cluster enabled? Requires `var.log_analytics_workspace_enabled` to be `true` to set this variable to `true`. | `bool` | `false` | no |
| <a name="input_monitor_metrics"></a> [monitor\_metrics](#input\_monitor\_metrics) | (Optional) Specifies a Prometheus add-on profile for the Kubernetes Cluster<br>object({<br>  annotations\_allowed = "(Optional) Specifies a comma-separated list of Kubernetes annotation keys that will be used in the resource's labels metric."<br>  labels\_allowed      = "(Optional) Specifies a Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric."<br>}) | <pre>object({<br>    annotations_allowed = optional(string)<br>    labels_allowed      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_msi_auth_for_monitoring_enabled"></a> [msi\_auth\_for\_monitoring\_enabled](#input\_msi\_auth\_for\_monitoring\_enabled) | (Optional) Is managed identity authentication for monitoring enabled? | `bool` | `null` | no |
| <a name="input_net_profile_dns_service_ip"></a> [net\_profile\_dns\_service\_ip](#input\_net\_profile\_dns\_service\_ip) | (Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_net_profile_outbound_type"></a> [net\_profile\_outbound\_type](#input\_net\_profile\_outbound\_type) | (Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer. | `string` | `"loadBalancer"` | no |
| <a name="input_net_profile_pod_cidr"></a> [net\_profile\_pod\_cidr](#input\_net\_profile\_pod\_cidr) | (Optional) The CIDR to use for pod IP addresses. This field can only be set when network\_plugin is set to kubenet. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_net_profile_service_cidr"></a> [net\_profile\_service\_cidr](#input\_net\_profile\_service\_cidr) | (Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_network_contributor_role_assigned_subnet_ids"></a> [network\_contributor\_role\_assigned\_subnet\_ids](#input\_network\_contributor\_role\_assigned\_subnet\_ids) | Create role assignments for the AKS Service Principal to be a Network Contributor on the subnets used for the AKS Cluster, key should be static string, value should be subnet's id | `map(string)` | `{}` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin to use for networking. | `string` | `"kubenet"` | no |
| <a name="input_network_plugin_mode"></a> [network\_plugin\_mode](#input\_network\_plugin\_mode) | (Optional) Specifies the network plugin mode used for building the Kubernetes network. Possible value is `Overlay`. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | (Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_node_os_channel_upgrade"></a> [node\_os\_channel\_upgrade](#input\_node\_os\_channel\_upgrade) | (Optional) The upgrade channel for this Kubernetes Cluster Nodes' OS Image. Possible values are `Unmanaged`, `SecurityPatch`, `NodeImage` and `None`. | `string` | `null` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | A map of node pools that need to be created and attached on the Kubernetes cluster. The key of the map can be the name of the node pool, and the key must be static string. The value of the map is a `node_pool` block as defined below:<br>map(object({<br>  name                          = (Required) The name of the Node Pool which should be created within the Kubernetes Cluster. Changing this forces a new resource to be created. A Windows Node Pool cannot have a `name` longer than 6 characters. A random suffix of 4 characters is always added to the name to avoid clashes during recreates.<br>  node\_count                    = (Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` (inclusive) for user pools and between `1` and `1000` (inclusive) for system pools and must be a value in the range `min_count` - `max_count`.<br>  tags                          = (Optional) A mapping of tags to assign to the resource. At this time there's a bug in the AKS API where Tags for a Node Pool are not stored in the correct case - you [may wish to use Terraform's `ignore_changes` functionality to ignore changes to the casing](https://www.terraform.io/language/meta-arguments/lifecycle#ignore_changess) until this is fixed in the AKS API.<br>  vm\_size                       = (Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created.<br>  host\_group\_id                 = (Optional) The fully qualified resource ID of the Dedicated Host Group to provision virtual machines from. Changing this forces a new resource to be created.<br>  capacity\_reservation\_group\_id = (Optional) Specifies the ID of the Capacity Reservation Group where this Node Pool should exist. Changing this forces a new resource to be created.<br>  custom\_ca\_trust\_enabled       = (Optional) Specifies whether to trust a Custom CA. This requires that the Preview Feature `Microsoft.ContainerService/CustomCATrustPreview` is enabled and the Resource Provider is re-registered, see [the documentation](https://learn.microsoft.com/en-us/azure/aks/custom-certificate-authority) for more information.<br>  enable\_auto\_scaling           = (Optional) Whether to enable [auto-scaler](https://docs.microsoft.com/azure/aks/cluster-autoscaler).<br>  enable\_host\_encryption        = (Optional) Should the nodes in this Node Pool have host encryption enabled? Changing this forces a new resource to be created.<br>  enable\_node\_public\_ip         = (Optional) Should each node have a Public IP Address? Changing this forces a new resource to be created.<br>  eviction\_policy               = (Optional) The Eviction Policy which should be used for Virtual Machines within the Virtual Machine Scale Set powering this Node Pool. Possible values are `Deallocate` and `Delete`. Changing this forces a new resource to be created. An Eviction Policy can only be configured when `priority` is set to `Spot` and will default to `Delete` unless otherwise specified.<br>  gpu\_instance                  = (Optional) Specifies the GPU MIG instance profile for supported GPU VM SKU. The allowed values are `MIG1g`, `MIG2g`, `MIG3g`, `MIG4g` and `MIG7g`. Changing this forces a new resource to be created.<br>  kubelet\_config = optional(object({<br>    cpu\_manager\_policy        = (Optional) Specifies the CPU Manager policy to use. Possible values are `none` and `static`, Changing this forces a new resource to be created.<br>    cpu\_cfs\_quota\_enabled     = (Optional) Is CPU CFS quota enforcement for containers enabled? Changing this forces a new resource to be created.<br>    cpu\_cfs\_quota\_period      = (Optional) Specifies the CPU CFS quota period value. Changing this forces a new resource to be created.<br>    image\_gc\_high\_threshold   = (Optional) Specifies the percent of disk usage above which image garbage collection is always run. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    image\_gc\_low\_threshold    = (Optional) Specifies the percent of disk usage lower than which image garbage collection is never run. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    topology\_manager\_policy   = (Optional) Specifies the Topology Manager policy to use. Possible values are `none`, `best-effort`, `restricted` or `single-numa-node`. Changing this forces a new resource to be created.<br>    allowed\_unsafe\_sysctls    = (Optional) Specifies the allow list of unsafe sysctls command or patterns (ending in `*`). Changing this forces a new resource to be created.<br>    container\_log\_max\_size\_mb = (Optional) Specifies the maximum size (e.g. 10MB) of container log file before it is rotated. Changing this forces a new resource to be created.<br>    container\_log\_max\_files   = (Optional) Specifies the maximum number of container log files that can be present for a container. must be at least 2. Changing this forces a new resource to be created.<br>    pod\_max\_pid               = (Optional) Specifies the maximum number of processes per pod. Changing this forces a new resource to be created.<br>  }))<br>  linux\_os\_config = optional(object({<br>    sysctl\_config = optional(object({<br>      fs\_aio\_max\_nr                      = (Optional) The sysctl setting fs.aio-max-nr. Must be between `65536` and `6553500`. Changing this forces a new resource to be created.<br>      fs\_file\_max                        = (Optional) The sysctl setting fs.file-max. Must be between `8192` and `12000500`. Changing this forces a new resource to be created.<br>      fs\_inotify\_max\_user\_watches        = (Optional) The sysctl setting fs.inotify.max\_user\_watches. Must be between `781250` and `2097152`. Changing this forces a new resource to be created.<br>      fs\_nr\_open                         = (Optional) The sysctl setting fs.nr\_open. Must be between `8192` and `20000500`. Changing this forces a new resource to be created.<br>      kernel\_threads\_max                 = (Optional) The sysctl setting kernel.threads-max. Must be between `20` and `513785`. Changing this forces a new resource to be created.<br>      net\_core\_netdev\_max\_backlog        = (Optional) The sysctl setting net.core.netdev\_max\_backlog. Must be between `1000` and `3240000`. Changing this forces a new resource to be created.<br>      net\_core\_optmem\_max                = (Optional) The sysctl setting net.core.optmem\_max. Must be between `20480` and `4194304`. Changing this forces a new resource to be created.<br>      net\_core\_rmem\_default              = (Optional) The sysctl setting net.core.rmem\_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>      net\_core\_rmem\_max                  = (Optional) The sysctl setting net.core.rmem\_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>      net\_core\_somaxconn                 = (Optional) The sysctl setting net.core.somaxconn. Must be between `4096` and `3240000`. Changing this forces a new resource to be created.<br>      net\_core\_wmem\_default              = (Optional) The sysctl setting net.core.wmem\_default. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>      net\_core\_wmem\_max                  = (Optional) The sysctl setting net.core.wmem\_max. Must be between `212992` and `134217728`. Changing this forces a new resource to be created.<br>      net\_ipv4\_ip\_local\_port\_range\_min   = (Optional) The sysctl setting net.ipv4.ip\_local\_port\_range min value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.<br>      net\_ipv4\_ip\_local\_port\_range\_max   = (Optional) The sysctl setting net.ipv4.ip\_local\_port\_range max value. Must be between `1024` and `60999`. Changing this forces a new resource to be created.<br>      net\_ipv4\_neigh\_default\_gc\_thresh1  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh1. Must be between `128` and `80000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_neigh\_default\_gc\_thresh2  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh2. Must be between `512` and `90000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_neigh\_default\_gc\_thresh3  = (Optional) The sysctl setting net.ipv4.neigh.default.gc\_thresh3. Must be between `1024` and `100000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_fin\_timeout           = (Optional) The sysctl setting net.ipv4.tcp\_fin\_timeout. Must be between `5` and `120`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_keepalive\_intvl       = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_intvl. Must be between `10` and `75`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_keepalive\_probes      = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_probes. Must be between `1` and `15`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_keepalive\_time        = (Optional) The sysctl setting net.ipv4.tcp\_keepalive\_time. Must be between `30` and `432000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_max\_syn\_backlog       = (Optional) The sysctl setting net.ipv4.tcp\_max\_syn\_backlog. Must be between `128` and `3240000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_max\_tw\_buckets        = (Optional) The sysctl setting net.ipv4.tcp\_max\_tw\_buckets. Must be between `8000` and `1440000`. Changing this forces a new resource to be created.<br>      net\_ipv4\_tcp\_tw\_reuse              = (Optional) Is sysctl setting net.ipv4.tcp\_tw\_reuse enabled? Changing this forces a new resource to be created.<br>      net\_netfilter\_nf\_conntrack\_buckets = (Optional) The sysctl setting net.netfilter.nf\_conntrack\_buckets. Must be between `65536` and `147456`. Changing this forces a new resource to be created.<br>      net\_netfilter\_nf\_conntrack\_max     = (Optional) The sysctl setting net.netfilter.nf\_conntrack\_max. Must be between `131072` and `1048576`. Changing this forces a new resource to be created.<br>      vm\_max\_map\_count                   = (Optional) The sysctl setting vm.max\_map\_count. Must be between `65530` and `262144`. Changing this forces a new resource to be created.<br>      vm\_swappiness                      = (Optional) The sysctl setting vm.swappiness. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>      vm\_vfs\_cache\_pressure              = (Optional) The sysctl setting vm.vfs\_cache\_pressure. Must be between `0` and `100`. Changing this forces a new resource to be created.<br>    }))<br>    transparent\_huge\_page\_enabled = (Optional) Specifies the Transparent Huge Page enabled configuration. Possible values are `always`, `madvise` and `never`. Changing this forces a new resource to be created.<br>    transparent\_huge\_page\_defrag  = (Optional) specifies the defrag configuration for Transparent Huge Page. Possible values are `always`, `defer`, `defer+madvise`, `madvise` and `never`. Changing this forces a new resource to be created.<br>    swap\_file\_size\_mb             = (Optional) Specifies the size of swap file on each node in MB. Changing this forces a new resource to be created.<br>  }))<br>  fips\_enabled       = (Optional) Should the nodes in this Node Pool have Federal Information Processing Standard enabled? Changing this forces a new resource to be created. FIPS support is in Public Preview - more information and details on how to opt into the Preview can be found in [this article](https://docs.microsoft.com/azure/aks/use-multiple-node-pools#add-a-fips-enabled-node-pool-preview).<br>  kubelet\_disk\_type  = (Optional) The type of disk used by kubelet. Possible values are `OS` and `Temporary`.<br>  max\_count          = (Optional) The maximum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be greater than or equal to `min_count`.<br>  max\_pods           = (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`.<br>  message\_of\_the\_day = (Optional) A base64-encoded string which will be written to /etc/motd after decoding. This allows customization of the message of the day for Linux nodes. It cannot be specified for Windows nodes and must be a static string (i.e. will be printed raw and not executed as a script). Changing this forces a new resource to be created.<br>  mode               = (Optional) Should this Node Pool be used for System or User resources? Possible values are `System` and `User`. Defaults to `User`.<br>  min\_count          = (Optional) The minimum number of nodes which should exist within this Node Pool. Valid values are between `0` and `1000` and must be less than or equal to `max_count`.<br>  node\_network\_profile = optional(object({<br>    node\_public\_ip\_tags = (Optional) Specifies a mapping of tags to the instance-level public IPs. Changing this forces a new resource to be created.<br>  }))<br>  node\_labels                  = (Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool.<br>  node\_public\_ip\_prefix\_id     = (Optional) Resource ID for the Public IP Addresses Prefix for the nodes in this Node Pool. `enable_node_public_ip` should be `true`. Changing this forces a new resource to be created.<br>  node\_taints                  = (Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g `key=value:NoSchedule`). Changing this forces a new resource to be created.<br>  orchestrator\_version         = (Optional) Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade). AKS does not require an exact patch version to be specified, minor version aliases such as `1.22` are also supported. - The minor version's latest GA patch is automatically chosen in that case. More details can be found in [the documentation](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#alias-minor-version). This version must be supported by the Kubernetes Cluster - as such the version of Kubernetes used on the Cluster/Control Plane may need to be upgraded first.<br>  os\_disk\_size\_gb              = (Optional) The Agent Operating System disk size in GB. Changing this forces a new resource to be created.<br>  os\_disk\_type                 = (Optional) The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created.<br>  os\_sku                       = (Optional) Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if OSType=Linux or `Windows2019` if OSType=Windows. And the default Windows OSSKU will be changed to `Windows2022` after Windows2019 is deprecated. Changing this forces a new resource to be created.<br>  os\_type                      = (Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are `Linux` and `Windows`. Defaults to `Linux`.<br>  pod\_subnet\_id                = (Optional) The ID of the Subnet where the pods in the Node Pool should exist. Changing this forces a new resource to be created.<br>  priority                     = (Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are `Regular` and `Spot`. Defaults to `Regular`. Changing this forces a new resource to be created.<br>  proximity\_placement\_group\_id = (Optional) The ID of the Proximity Placement Group where the Virtual Machine Scale Set that powers this Node Pool will be placed. Changing this forces a new resource to be created. When setting `priority` to Spot - you must configure an `eviction_policy`, `spot_max_price` and add the applicable `node_labels` and `node_taints` [as per the Azure Documentation](https://docs.microsoft.com/azure/aks/spot-node-pool).<br>  spot\_max\_price               = (Optional) The maximum price you're willing to pay in USD per Virtual Machine. Valid values are `-1` (the current on-demand price for a Virtual Machine) or a positive value with up to five decimal places. Changing this forces a new resource to be created. This field can only be configured when `priority` is set to `Spot`.<br>  scale\_down\_mode              = (Optional) Specifies how the node pool should deal with scaled-down nodes. Allowed values are `Delete` and `Deallocate`. Defaults to `Delete`.<br>  snapshot\_id                  = (Optional) The ID of the Snapshot which should be used to create this Node Pool. Changing this forces a new resource to be created.<br>  ultra\_ssd\_enabled            = (Optional) Used to specify whether the UltraSSD is enabled in the Node Pool. Defaults to `false`. See [the documentation](https://docs.microsoft.com/azure/aks/use-ultra-disks) for more information. Changing this forces a new resource to be created.<br>  vnet\_subnet\_id               = (Optional) The ID of the Subnet where this Node Pool should exist. Changing this forces a new resource to be created. A route table must be configured on this Subnet.<br>  upgrade\_settings = optional(object({<br>    max\_surge = string<br>  }))<br>  windows\_profile = optional(object({<br>    outbound\_nat\_enabled = optional(bool, true)<br>  }))<br>  workload\_runtime = (Optional) Used to specify the workload runtime. Allowed values are `OCIContainer` and `WasmWasi`. WebAssembly System Interface node pools are in Public Preview - more information and details on how to opt into the preview can be found in [this article](https://docs.microsoft.com/azure/aks/use-wasi-node-pools)<br>  zones            = (Optional) Specifies a list of Availability Zones in which this Kubernetes Cluster Node Pool should be located. Changing this forces a new Kubernetes Cluster Node Pool to be created.<br>  create\_before\_destroy = (Optional) Create a new node pool before destroy the old one when Terraform must update an argument that cannot be updated in-place. Set this argument to `true` will add add a random suffix to pool's name to avoid conflict. Default to `true`.<br>})) | <pre>map(object({<br>    name                          = string<br>    node_count                    = optional(number)<br>    tags                          = optional(map(string))<br>    vm_size                       = string<br>    host_group_id                 = optional(string)<br>    capacity_reservation_group_id = optional(string)<br>    custom_ca_trust_enabled       = optional(bool)<br>    enable_auto_scaling           = optional(bool)<br>    enable_host_encryption        = optional(bool)<br>    enable_node_public_ip         = optional(bool)<br>    eviction_policy               = optional(string)<br>    gpu_instance                  = optional(string)<br>    kubelet_config = optional(object({<br>      cpu_manager_policy        = optional(string)<br>      cpu_cfs_quota_enabled     = optional(bool)<br>      cpu_cfs_quota_period      = optional(string)<br>      image_gc_high_threshold   = optional(number)<br>      image_gc_low_threshold    = optional(number)<br>      topology_manager_policy   = optional(string)<br>      allowed_unsafe_sysctls    = optional(set(string))<br>      container_log_max_size_mb = optional(number)<br>      container_log_max_files   = optional(number)<br>      pod_max_pid               = optional(number)<br>    }))<br>    linux_os_config = optional(object({<br>      sysctl_config = optional(object({<br>        fs_aio_max_nr                      = optional(number)<br>        fs_file_max                        = optional(number)<br>        fs_inotify_max_user_watches        = optional(number)<br>        fs_nr_open                         = optional(number)<br>        kernel_threads_max                 = optional(number)<br>        net_core_netdev_max_backlog        = optional(number)<br>        net_core_optmem_max                = optional(number)<br>        net_core_rmem_default              = optional(number)<br>        net_core_rmem_max                  = optional(number)<br>        net_core_somaxconn                 = optional(number)<br>        net_core_wmem_default              = optional(number)<br>        net_core_wmem_max                  = optional(number)<br>        net_ipv4_ip_local_port_range_min   = optional(number)<br>        net_ipv4_ip_local_port_range_max   = optional(number)<br>        net_ipv4_neigh_default_gc_thresh1  = optional(number)<br>        net_ipv4_neigh_default_gc_thresh2  = optional(number)<br>        net_ipv4_neigh_default_gc_thresh3  = optional(number)<br>        net_ipv4_tcp_fin_timeout           = optional(number)<br>        net_ipv4_tcp_keepalive_intvl       = optional(number)<br>        net_ipv4_tcp_keepalive_probes      = optional(number)<br>        net_ipv4_tcp_keepalive_time        = optional(number)<br>        net_ipv4_tcp_max_syn_backlog       = optional(number)<br>        net_ipv4_tcp_max_tw_buckets        = optional(number)<br>        net_ipv4_tcp_tw_reuse              = optional(bool)<br>        net_netfilter_nf_conntrack_buckets = optional(number)<br>        net_netfilter_nf_conntrack_max     = optional(number)<br>        vm_max_map_count                   = optional(number)<br>        vm_swappiness                      = optional(number)<br>        vm_vfs_cache_pressure              = optional(number)<br>      }))<br>      transparent_huge_page_enabled = optional(string)<br>      transparent_huge_page_defrag  = optional(string)<br>      swap_file_size_mb             = optional(number)<br>    }))<br>    fips_enabled       = optional(bool)<br>    kubelet_disk_type  = optional(string)<br>    max_count          = optional(number)<br>    max_pods           = optional(number)<br>    message_of_the_day = optional(string)<br>    mode               = optional(string, "User")<br>    min_count          = optional(number)<br>    node_network_profile = optional(object({<br>      node_public_ip_tags = optional(map(string))<br>    }))<br>    node_labels                  = optional(map(string))<br>    node_public_ip_prefix_id     = optional(string)<br>    node_taints                  = optional(list(string))<br>    orchestrator_version         = optional(string)<br>    os_disk_size_gb              = optional(number)<br>    os_disk_type                 = optional(string, "Managed")<br>    os_sku                       = optional(string)<br>    os_type                      = optional(string, "Linux")<br>    pod_subnet_id                = optional(string)<br>    priority                     = optional(string, "Regular")<br>    proximity_placement_group_id = optional(string)<br>    spot_max_price               = optional(number)<br>    scale_down_mode              = optional(string, "Delete")<br>    snapshot_id                  = optional(string)<br>    ultra_ssd_enabled            = optional(bool)<br>    vnet_subnet_id               = optional(string)<br>    upgrade_settings = optional(object({<br>      max_surge = string<br>    }))<br>    windows_profile = optional(object({<br>      outbound_nat_enabled = optional(bool, true)<br>    }))<br>    workload_runtime      = optional(string)<br>    zones                 = optional(set(string))<br>    create_before_destroy = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_node_resource_group"></a> [node\_resource\_group](#input\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable or Disable the OIDC issuer URL. Defaults to false. | `bool` | `false` | no |
| <a name="input_only_critical_addons_enabled"></a> [only\_critical\_addons\_enabled](#input\_only\_critical\_addons\_enabled) | (Optional) Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint. Changing this forces a new resource to be created. | `bool` | `null` | no |
| <a name="input_open_service_mesh_enabled"></a> [open\_service\_mesh\_enabled](#input\_open\_service\_mesh\_enabled) | Is Open Service Mesh enabled? For more details, please visit [Open Service Mesh for AKS](https://docs.microsoft.com/azure/aks/open-service-mesh-about). | `bool` | `null` | no |
| <a name="input_orchestrator_version"></a> [orchestrator\_version](#input\_orchestrator\_version) | Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region | `string` | `null` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Disk size of nodes in GBs. | `number` | `50` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Managed`. Changing this forces a new resource to be created. | `string` | `"Managed"` | no |
| <a name="input_os_sku"></a> [os\_sku](#input\_os\_sku) | (Optional) Specifies the OS SKU used by the agent pool. Possible values include: `Ubuntu`, `CBLMariner`, `Mariner`, `Windows2019`, `Windows2022`. If not specified, the default is `Ubuntu` if OSType=Linux or `Windows2019` if OSType=Windows. And the default Windows OSSKU will be changed to `Windows2022` after Windows2019 is deprecated. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_pod_subnet_id"></a> [pod\_subnet\_id](#input\_pod\_subnet\_id) | (Optional) The ID of the Subnet where the pods in the default Node Pool should exist. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Optional) The prefix for the resources created in the specified Azure Resource Group. Omitting this variable requires both `var.cluster_log_analytics_workspace_name` and `var.cluster_name` have been set. | `string` | `""` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | If true cluster API server will be exposed only on internal IP address and available only in cluster vnet. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | (Optional) Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | (Optional) Either the ID of Private DNS Zone which should be delegated to this Cluster, `System` to have AKS manage this or `None`. In case of `None` you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_public_ssh_key"></a> [public\_ssh\_key](#input\_public\_ssh\_key) | A custom ssh key to control access to the AKS cluster. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_rbac_aad"></a> [rbac\_aad](#input\_rbac\_aad) | (Optional) Is Azure Active Directory integration enabled? | `bool` | `true` | no |
| <a name="input_rbac_aad_admin_group_object_ids"></a> [rbac\_aad\_admin\_group\_object\_ids](#input\_rbac\_aad\_admin\_group\_object\_ids) | Object ID of groups with admin access. | `list(string)` | `null` | no |
| <a name="input_rbac_aad_azure_rbac_enabled"></a> [rbac\_aad\_azure\_rbac\_enabled](#input\_rbac\_aad\_azure\_rbac\_enabled) | (Optional) Is Role Based Access Control based on Azure AD enabled? | `bool` | `null` | no |
| <a name="input_rbac_aad_client_app_id"></a> [rbac\_aad\_client\_app\_id](#input\_rbac\_aad\_client\_app\_id) | The Client ID of an Azure Active Directory Application. | `string` | `null` | no |
| <a name="input_rbac_aad_managed"></a> [rbac\_aad\_managed](#input\_rbac\_aad\_managed) | Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration. | `bool` | `false` | no |
| <a name="input_rbac_aad_server_app_id"></a> [rbac\_aad\_server\_app\_id](#input\_rbac\_aad\_server\_app\_id) | The Server ID of an Azure Active Directory Application. | `string` | `null` | no |
| <a name="input_rbac_aad_server_app_secret"></a> [rbac\_aad\_server\_app\_secret](#input\_rbac\_aad\_server\_app\_secret) | The Server Secret of an Azure Active Directory Application. | `string` | `null` | no |
| <a name="input_rbac_aad_tenant_id"></a> [rbac\_aad\_tenant\_id](#input\_rbac\_aad\_tenant\_id) | (Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name to be imported | `string` | n/a | yes |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Enable Role Based Access Control. | `bool` | `false` | no |
| <a name="input_run_command_enabled"></a> [run\_command\_enabled](#input\_run\_command\_enabled) | (Optional) Whether to enable run command for the cluster or not. | `bool` | `true` | no |
| <a name="input_scale_down_mode"></a> [scale\_down\_mode](#input\_scale\_down\_mode) | (Optional) Specifies the autoscaling behaviour of the Kubernetes Cluster. If not specified, it defaults to `Delete`. Possible values include `Delete` and `Deallocate`. Changing this forces a new resource to be created. | `string` | `"Delete"` | no |
| <a name="input_secret_rotation_enabled"></a> [secret\_rotation\_enabled](#input\_secret\_rotation\_enabled) | Is secret rotation enabled? This variable is only used when `key_vault_secrets_provider_enabled` is `true` and defaults to `false` | `bool` | `false` | no |
| <a name="input_secret_rotation_interval"></a> [secret\_rotation\_interval](#input\_secret\_rotation\_interval) | The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true` and defaults to `2m` | `string` | `"2m"` | no |
| <a name="input_service_mesh_profile"></a> [service\_mesh\_profile](#input\_service\_mesh\_profile) | `mode` - (Required) The mode of the service mesh. Possible value is `Istio`.<br>`internal_ingress_gateway_enabled` - (Optional) Is Istio Internal Ingress Gateway enabled? Defaults to `true`.<br>`external_ingress_gateway_enabled` - (Optional) Is Istio External Ingress Gateway enabled? Defaults to `true`. | <pre>object({<br>    mode                             = string<br>    internal_ingress_gateway_enabled = optional(bool, true)<br>    external_ingress_gateway_enabled = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free`, `Standard` and `Premium` | `string` | `"Free"` | no |
| <a name="input_snapshot_id"></a> [snapshot\_id](#input\_snapshot\_id) | (Optional) The ID of the Snapshot which should be used to create this default Node Pool. `temporary_name_for_rotation` must be specified when changing this property. | `string` | `null` | no |
| <a name="input_storage_profile_blob_driver_enabled"></a> [storage\_profile\_blob\_driver\_enabled](#input\_storage\_profile\_blob\_driver\_enabled) | (Optional) Is the Blob CSI driver enabled? Defaults to `false` | `bool` | `false` | no |
| <a name="input_storage_profile_disk_driver_enabled"></a> [storage\_profile\_disk\_driver\_enabled](#input\_storage\_profile\_disk\_driver\_enabled) | (Optional) Is the Disk CSI driver enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_storage_profile_disk_driver_version"></a> [storage\_profile\_disk\_driver\_version](#input\_storage\_profile\_disk\_driver\_version) | (Optional) Disk CSI Driver version to be used. Possible values are `v1` and `v2`. Defaults to `v1`. | `string` | `"v1"` | no |
| <a name="input_storage_profile_enabled"></a> [storage\_profile\_enabled](#input\_storage\_profile\_enabled) | Enable storage profile | `bool` | `false` | no |
| <a name="input_storage_profile_file_driver_enabled"></a> [storage\_profile\_file\_driver\_enabled](#input\_storage\_profile\_file\_driver\_enabled) | (Optional) Is the File CSI driver enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_storage_profile_snapshot_controller_enabled"></a> [storage\_profile\_snapshot\_controller\_enabled](#input\_storage\_profile\_snapshot\_controller\_enabled) | (Optional) Is the Snapshot Controller enabled? Defaults to `true` | `bool` | `true` | no |
| <a name="input_support_plan"></a> [support\_plan](#input\_support\_plan) | The support plan which should be used for this Kubernetes Cluster. Possible values are `KubernetesOfficial` and `AKSLongTermSupport`. | `string` | `"KubernetesOfficial"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Any tags that should be present on the AKS cluster resources | `map(string)` | `{}` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | (Optional) Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing. the `var.agents_size` is no longer ForceNew and can be resized by specifying `temporary_name_for_rotation` | `string` | `null` | no |
| <a name="input_tracing_tags_enabled"></a> [tracing\_tags\_enabled](#input\_tracing\_tags\_enabled) | Whether enable tracing tags that generated by BridgeCrew Yor. | `bool` | `false` | no |
| <a name="input_tracing_tags_prefix"></a> [tracing\_tags\_prefix](#input\_tracing\_tags\_prefix) | Default prefix for generated tracing tags | `string` | `"avm_"` | no |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | (Optional) Used to specify whether the UltraSSD is enabled in the Default Node Pool. Defaults to false. | `bool` | `false` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | (Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_web_app_routing"></a> [web\_app\_routing](#input\_web\_app\_routing) | object({<br>  dns\_zone\_id = "(Required) Specifies the ID of the DNS Zone in which DNS entries are created for applications deployed to the cluster when Web App Routing is enabled."<br>}) | <pre>object({<br>    dns_zone_id = string<br>  })</pre> | `null` | no |
| <a name="input_workload_autoscaler_profile"></a> [workload\_autoscaler\_profile](#input\_workload\_autoscaler\_profile) | `keda_enabled` - (Optional) Specifies whether KEDA Autoscaler can be used for workloads.<br>`vertical_pod_autoscaler_enabled` - (Optional) Specifies whether Vertical Pod Autoscaler should be enabled. | <pre>object({<br>    keda_enabled                    = optional(bool, false)<br>    vertical_pod_autoscaler_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable or Disable Workload Identity. Defaults to false. | `bool` | `false` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | The `azurerm_kubernetes_cluster`'s id. |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The `aurerm_kubernetes-cluster`'s name. |
| <a name="output_azure_policy_enabled"></a> [azure\_policy\_enabled](#output\_azure\_policy\_enabled) | The `azurerm_kubernetes_cluster`'s `azure_policy_enabled` argument. Should the Azure Policy Add-On be enabled? For more details please visit [Understand Azure Policy for Azure Kubernetes Service](https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/rego-for-aks) |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the Azure Kubernetes Managed Cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | The `azurerm_kubernetes_cluster`'s `identity` block. |
| <a name="output_cluster_portal_fqdn"></a> [cluster\_portal\_fqdn](#output\_cluster\_portal\_fqdn) | The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_cluster_private_fqdn"></a> [cluster\_private\_fqdn](#output\_cluster\_private\_fqdn) | The FQDN for the Kubernetes Cluster when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_host"></a> [host](#output\_host) | The `host` in the `azurerm_kubernetes_cluster`'s `kube_config` block. The Kubernetes cluster server host. |
| <a name="output_ingress_application_gateway"></a> [ingress\_application\_gateway](#output\_ingress\_application\_gateway) | The `azurerm_kubernetes_cluster`'s `ingress_application_gateway` block. |
| <a name="output_ingress_application_gateway_enabled"></a> [ingress\_application\_gateway\_enabled](#output\_ingress\_application\_gateway\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `ingress_application_gateway` block? |
| <a name="output_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#output\_key\_vault\_secrets\_provider) | The `azurerm_kubernetes_cluster`'s `key_vault_secrets_provider` block. |
| <a name="output_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#output\_key\_vault\_secrets\_provider\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `key_vault_secrets_provider` block? |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The `azurerm_kubernetes_cluster`'s `kubelet_identity` block. |
| <a name="output_location"></a> [location](#output\_location) | The `azurerm_kubernetes_cluster`'s `location` argument. (Required) The location where the Managed Kubernetes Cluster should be created. |
| <a name="output_network_profile"></a> [network\_profile](#output\_network\_profile) | The `azurerm_kubernetes_cluster`'s `network_profile` block |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |
| <a name="output_oms_agent"></a> [oms\_agent](#output\_oms\_agent) | The `azurerm_kubernetes_cluster`'s `oms_agent` argument. |
| <a name="output_oms_agent_enabled"></a> [oms\_agent\_enabled](#output\_oms\_agent\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `oms_agent` block? |

#### The following resources are created by this module:


- resource.azurerm_kubernetes_cluster.aks (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#7)
- resource.azurerm_kubernetes_cluster_node_pool.node_pool_create_after_destroy (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/node_pool.tf#157)
- resource.azurerm_kubernetes_cluster_node_pool.node_pool_create_before_destroy (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/node_pool.tf#6)
- resource.null_resource.http_proxy_config_no_proxy_keeper (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#632)
- resource.null_resource.kubernetes_cluster_name_keeper (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#605)
- resource.null_resource.kubernetes_version_keeper (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#611)
- resource.null_resource.pool_name_keeper (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/node_pool.tf#299)
- data source.azurerm_resource_group.rg (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#3)
- data source.azurerm_subscription.current (/usr/agent/azp/_work/1/s/amn-az-tfm-aks/main.tf#1)


## Example Scenario

Create public AKS cluster with RBAC diabled and log analytics workspace not configured. <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create virtual network<br />- Create user assigned Identity<br /> - Create AKS cluster

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric  = true
}

resource "random_id" "prefix" {
  byte_length = 8
}

locals {
  resource_group_suffix = "rg"
  aks_suffix            = "aks"
  vnet_suvnetffix           = "vnet"
  environment_suffix    = "t01"
  mgid_suffix           = "mgid"
  us_region_abbreviations = {
    centralus       = "cus"
    eastus          = "eus"
    eastus2         = "eus2"
    westus          = "wus"
    northcentralus  = "ncus"
    southcentralus  = "scus"
    westcentralus   = "wcus"
    westus2         = "wus2"
  }
  region_abbreviation = local.us_region_abbreviations[var.location]
  resource_group_name   = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  aks_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.aks_suffix}-${local.environment_suffix}"
  vnet_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.vnet_suvnetffix}-${local.environment_suffix}"
  mgid_name          = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.mgid_suffix}-${local.environment_suffix}"
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl
module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source                  = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name     = local.resource_group_name
  location                = var.location
  tags                    = var.tags
}

module "virtual_network" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-virtual-network?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  vnetwork_name                  = local.vnet_name
  vnet_address_space             = var.vnet_address_space
  create_network_watcher         = false
  subnets                        = var.subnets
  tags                           = var.tags
}

module "user_assigned_identity" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on = [module.rg]
  source                      = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-user-assigned-identity?ref=v1.0.0"
  resource_group_name         = module.rg.resource_group_name
  location                    = var.location
  user_assigned_identity_name = local.mgid_name
  tags                        = var.tags
}

locals {
  nodes = {
    for i in range(2) : "worker${i}" => {
      name                  = substr("worker${i}${random_id.prefix.hex}", 0, 8)
      vm_size               = "Standard_B4ls_v2"
      node_count            = 1
      vnet_subnet_id        = module.virtual_network.subnet_ids[0]
      create_before_destroy = i % 2 == 0
      tags                  = var.tags
    }
  }
}

module "aks" {

  #checkov:skip=CKV_AZURE_168: "Ensure Azure Kubernetes Cluster (AKS) nodes should use a minimum number of 50 pods."
  #checkov:skip=CKV_AZURE_115: "Ensure that AKS enables private clusters"
  #checkov:skip=CKV2_AZURE_29: "Ensure AKS cluster has Azure CNI networking enabled"
  #checkov:skip=CKV_AZURE_227: "Ensure that the AKS cluster encrypt temp disks, caches, and data flows between Compute and Storage resources"
  #checkov:skip=CKV_AZURE_227: "Ensure that the AKS cluster encrypt temp disks, caches, and data flows between Compute and Storage resources"
  #checkov:skip=CKV_AZURE_5: "Ensure RBAC is enabled on AKS clusters"
  #checkov:skip=CKV_AZURE_116: "Ensure that AKS uses Azure Policies Add-on"
  #checkov:skip=CKV_AZURE_226: "Ensure ephemeral disks are used for OS disks"
  #checkov:skip=CKV_AZURE_232: "Ensure that only critical system pods run on system nodes"
  depends_on = [module.virtual_network, module.user_assigned_identity, module.rg]
  source = "../"

  prefix                            = "prefix-${random_id.prefix.hex}"
  kubernetes_version                = var.kubernetes_version
  resource_group_name               = local.resource_group_name
  cluster_name                      = local.aks_name
  os_disk_size_gb                   = 30
  network_plugin                    = var.network_plugin
  network_policy                    = var.network_policy
  network_plugin_mode               = var.network_plugin_mode
  sku_tier                          = "Standard"
  identity_type                     = "UserAssigned"
  identity_ids                      = [module.user_assigned_identity.mi_id]
  rbac_aad                          = false
  // role_based_access_control_enabled = true
  log_analytics_workspace_enabled   = true
  microsoft_defender_enabled        = false
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  vnet_subnet_id                    = module.virtual_network.subnet_ids[0]
  node_pools                        = local.nodes
  log_analytics_workspace_id        = var.log_analytics_workspace_id
  tags                              = var.tags
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location                = "westus2"
vnet_address_space      = ["10.81.0.0/26"]
network_plugin          = "azure"
network_policy          = "calico"
network_plugin_mode     = "overlay"
kubernetes_version      = "1.29.2"
log_analytics_workspace_id = "/subscriptions/43c5a646-c00c-4c59-a332-df854c5dd08c/resourceGroups/co-wus2-enterprisemonitor-rg-s01/providers/Microsoft.OperationalInsights/workspaces/amn-co-wus2-enterprisemonitor-loga-d01"
subnets = {
  mgnt_subnet1 = {
    subnet_name           = "kube-subnet"
    subnet_address_prefix = ["10.81.0.0/27"]
  }
}

tags = {
  charge-to       = "101-71200-5000-9500",
  environment     = "test",
  application     = "Platform Services",
  product         = "Platform Services",
  amnonecomponent = "shared",
  role            = "infrastructure-tf-unit-test",
  managed-by      = "cloud.engineers@amnhealthcare.com",
  owner           = "cloud.engineers@amnhealthcare.com"
}
```
Once the resources are created, the pipeline runs tests to ensure everything is functioning as expected. Upon successful completion of these tests, the pipeline will automatically tear down all the created resources.
<!-- END_TF_DOCS -->