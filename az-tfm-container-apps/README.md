<!-- BEGIN_TF_DOCS -->
# Introduction 

Terraform module to deploy and manage container apps in Azure.

## Requirements
 - **Terraform**: `~> 1.6`
 - **Provider**: `azurerm ~> 3.71`

#### Content of the module "main.tf" file.
```hcl

resource "azurerm_container_app" "container_app" {
  for_each = var.container_apps

  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  name                         = each.value.name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = each.value.revision_mode

  workload_profile_name = each.value.workload_profile_name

  template {
    max_replicas    = each.value.template.max_replicas
    min_replicas    = each.value.template.min_replicas
    revision_suffix = each.value.template.revision_suffix

    dynamic "init_container" {
      for_each = each.value.template.init_containers == null ? [] : each.value.template.init_containers

      content {
        image   = init_container.value.image
        name    = init_container.value.name
        args    = init_container.value.args
        command = init_container.value.command
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory

        dynamic "env" {
          for_each = init_container.value.env == null ? [] : init_container.value.env
          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts == null ? [] : init_container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "container" {
      for_each = each.value.template.containers
      content {
        cpu     = container.value.cpu
        image   = container.value.image
        memory  = container.value.memory
        name    = container.value.name
        args    = container.value.args
        command = container.value.command

        dynamic "env" {
          for_each = container.value.env == null ? [] : container.value.env
          content {
            name        = env.value.name
            secret_name = env.value.secret_name
            value       = env.value.value
          }
        }
        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]
          content {
            port                             = liveness_probe.value.port
            transport                        = liveness_probe.value.transport
            failure_count_threshold          = liveness_probe.value.failure_count_threshold
            host                             = liveness_probe.value.host
            initial_delay                    = liveness_probe.value.initial_delay
            interval_seconds                 = liveness_probe.value.interval_seconds
            path                             = liveness_probe.value.path
            timeout                          = liveness_probe.value.timeout
            termination_grace_period_seconds = liveness_probe.value.termination_grace_period_seconds
            dynamic "header" {
              for_each = liveness_probe.value.header == null ? [] : [liveness_probe.value.header]
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]
          content {
            port                    = readiness_probe.value.port
            transport               = readiness_probe.value.transport
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            host                    = readiness_probe.value.host
            interval_seconds        = readiness_probe.value.interval_seconds
            path                    = readiness_probe.value.path
            success_count_threshold = readiness_probe.value.success_count_threshold
            timeout                 = readiness_probe.value.timeout

            dynamic "header" {
              for_each = readiness_probe.value.header == null ? [] : [readiness_probe.value.header]
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }
        dynamic "startup_probe" {
          for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]
          content {
            port                             = startup_probe.value.port
            transport                        = startup_probe.value.transport
            failure_count_threshold          = startup_probe.value.failure_count_threshold
            host                             = startup_probe.value.host
            interval_seconds                 = startup_probe.value.interval_seconds
            path                             = startup_probe.value.path
            timeout                          = startup_probe.value.timeout
            termination_grace_period_seconds = startup_probe.value.termination_grace_period_seconds

            dynamic "header" {
              for_each = startup_probe.value.header == null ? [] : [startup_probe.value.header]
              content {
                name  = header.value.name
                value = header.value.name
              }
            }
          }
        }
        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts == null ? [] : container.value.volume_mounts
          content {
            name = volume_mounts.value.name
            path = volume_mounts.value.path
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = each.value.template.azure_queue_scale_rule == null ? [] : [each.value.template.azure_queue_scale_rule]
      content {
        name         = azure_queue_scale_rule.value.name
        queue_length = azure_queue_scale_rule.value.queue_length
        queue_name   = azure_queue_scale_rule.value.queue_name
        authentication {
          secret_name       = azure_queue_scale_rule.value.authentication.secret_name
          trigger_parameter = azure_queue_scale_rule.value.authentication.trigger_parameter
        }
      }

    }

    dynamic "custom_scale_rule" {
      for_each = each.value.template.custom_scale_rule == null ? [] : [each.value.template.custom_scale_rule]
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata = {
          "name" = custom_scale_rule.value.metadata.name
        }
        authentication {
          secret_name       = custom_scale_rule.value.authentication.secret_name
          trigger_parameter = custom_scale_rule.value.authentication.trigger_parameter
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = each.value.template.http_scale_rule == null ? [] : [each.value.template.http_scale_rule]
      content {
        concurrent_requests = http_scale_rule.value.concurrent_requests
        name                = http_scale_rule.value.name
        authentication {
          secret_name       = http_scale_rule.value.authentication.secret_name
          trigger_parameter = http_scale_rule.value.authentication.trigger_parameter
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = each.value.template.tcp_scale_rule == null ? [] : [each.value.template.tcp_scale_rule]
      content {
        concurrent_requests = tcp_scale_rule.value.concurrent_requests
        name                = tcp_scale_rule.value.name
        authentication {
          secret_name       = tcp_scale_rule.value.authentication.secret_name
          trigger_parameter = tcp_scale_rule.value.authentication.trigger_parameter
        }
      }
    }
    dynamic "volume" {
      for_each = each.value.template.volume == null ? [] : each.value.template.volume

      content {
        name         = volume.value.name
        storage_name = volume.value.storage_name
        storage_type = volume.value.storage_type
      }
    }
  }
  dynamic "dapr" {
    for_each = each.value.dapr == null ? [] : [each.value.dapr]
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }
  dynamic "identity" {
    for_each = each.value.identity == null ? [] : [each.value.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "ingress" {
    for_each = each.value.ingress == null ? [] : [each.value.ingress]

    content {
      target_port                = ingress.value.target_port
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled           = ingress.value.external_enabled
      transport                  = ingress.value.transport
      exposed_port               = ingress.value.exposed_port

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight == null ? [] : [ingress.value.traffic_weight]

        content {
          percentage      = traffic_weight.value.percentage
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }
      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restrictions == null ? [] : ingress.value.ip_security_restrictions

        content {
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
          description      = ip_security_restriction.value.description
        }
      }
    }
  }
  dynamic "registry" {
    for_each = each.value.registry == null ? [] : each.value.registry

    content {
      server               = registry.value.server
      identity             = registry.value.identity
      password_secret_name = registry.value.password_secret_name
      username             = registry.value.username
    }
  }
  dynamic "secret" {
    for_each = each.value.secret == null ? [] : each.value.secret

    content {
      name                = secret.value.name
      value               = secret.value.value
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
    }
  }
}
```
#### This module has the following input variables:  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Container App Environment ID. | `string` | n/a | yes |
| <a name="input_container_apps"></a> [container\_apps](#input\_container\_apps) | The container apps to deploy. | <pre>map(object({<br>    name                  = string<br>    revision_mode         = string<br>    workload_profile_name = optional(string)<br><br>    template = object({<br>      max_replicas    = optional(number)<br>      min_replicas    = optional(number)<br>      revision_suffix = optional(string)<br><br>      init_containers = optional(set(object({<br>        image   = string<br>        name    = string<br>        args    = optional(list(string))<br>        command = optional(list(string))<br>        cpu     = optional(number)<br>        memory  = optional(string)<br><br>        env = optional(list(object({<br>          name        = string<br>          secret_name = optional(string)<br>          value       = optional(string)<br>        })))<br><br>        volume_mounts = optional(list(object({<br>          name = string<br>          path = string<br>        })))<br>      })), [])<br><br>      containers = set(object({<br>        name    = string<br>        image   = string<br>        args    = optional(list(string))<br>        command = optional(list(string))<br>        cpu     = string<br>        memory  = string<br><br>        env = optional(set(object({<br>          name        = string<br>          secret_name = optional(string)<br>          value       = optional(string)<br>        })))<br>        liveness_probe = optional(object({<br>          port                             = number<br>          transport                        = string<br>          failure_count_threshold          = optional(number)<br>          host                             = optional(string)<br>          initial_delay                    = optional(number, 1)<br>          interval_seconds                 = optional(number, 10)<br>          path                             = optional(string)<br>          timeout                          = optional(number, 1)<br>          termination_grace_period_seconds = optional(number)<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        readiness_probe = optional(object({<br>          port                    = number<br>          transport               = string<br>          failure_count_threshold = optional(number)<br>          host                    = optional(string)<br>          interval_seconds        = optional(number, 10)<br>          path                    = optional(string)<br>          success_count_threshold = optional(number, 3)<br>          timeout                 = optional(number)<br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        startup_probe = optional(object({<br>          port                             = number<br>          transport                        = string<br>          failure_count_threshold          = optional(number)<br>          host                             = optional(string)<br>          interval_seconds                 = optional(number, 10)<br>          path                             = optional(string)<br>          timeout                          = optional(number)<br>          termination_grace_period_seconds = optional(number)<br><br>          header = optional(object({<br>            name  = string<br>            value = string<br>          }))<br>        }))<br>        volume_mounts = optional(list(object({<br>          name = string<br>          path = string<br>        })))<br>      }))<br><br>      azure_queue_scale_rule = optional(object({<br>        name         = string<br>        queue_length = number<br>        queue_name   = string<br>        authentication = optional(object({<br>          secret_name       = string<br>          trigger_parameter = string<br>        }))<br>      }))<br><br>      custom_scale_rule = optional(object({<br>        name             = string<br>        custom_rule_type = string<br>        metadata         = optional(map(string))<br>        authentication = optional(object({<br>          secret_name       = string<br>          trigger_parameter = string<br>        }))<br>      }))<br><br>      http_scale_rule = optional(object({<br>        concurrent_requests = number<br>        name                = string<br>        authentication = optional(object({<br>          secret_name       = string<br>          trigger_parameter = string<br>        }))<br>      }))<br><br>      tcp_scale_rule = optional(object({<br>        concurrent_requests = number<br>        name                = string<br>        authentication = optional(object({<br>          secret_name       = string<br>          trigger_parameter = string<br>        }))<br>      }))<br><br>      volume = optional(set(object({<br>        name         = string<br>        storage_name = optional(string)<br>        storage_type = optional(string)<br>      })))<br>    })<br><br>    dapr = optional(object({<br>      app_id       = string<br>      app_port     = number<br>      app_protocol = optional(string)<br>    }))<br><br>    identity = optional(object({<br>      type         = string<br>      identity_ids = optional(list(string))<br>    }))<br><br>    ingress = optional(object({<br>      target_port                = number<br>      allow_insecure_connections = optional(bool, false)<br>      external_enabled           = optional(bool, false)<br>      transport                  = optional(string)<br>      exposed_port               = optional(number)<br><br>      traffic_weight = object({<br>        percentage      = number<br>        label           = optional(string)<br>        latest_revision = optional(string)<br>        revision_suffix = optional(string)<br>      })<br><br>      ip_security_restrictions = optional(list(object({<br>        action           = string<br>        ip_address_range = string<br>        name             = string<br>        description      = optional(string)<br>      })), [])<br>    }))<br><br>    registry = optional(list(object({<br>      server               = string<br>      username             = optional(string)<br>      password_secret_name = optional(string)<br>      identity             = optional(string)<br>    })))<br><br>    secret = optional(list(object({<br>      name                = string<br>      value               = optional(string)<br>      identity            = optional(string)<br>      key_vault_secret_id = optional(string)<br>    })))<br><br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

#### This module has the following outputs:
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_id"></a> [container\_app\_id](#output\_container\_app\_id) | value of container app id |
| <a name="output_container_app_name"></a> [container\_app\_name](#output\_container\_app\_name) | value of container app name |

#### The following resources are created by this module:


- resource.azurerm_container_app.container_app (/usr/agent/azp/_work/1/s/amn-az-tfm-container-apps/main.tf#2)


## Example Scenario

Create container apps <br /><br /> The following steps in example to using this module:<br /> - Create resource group<br /> - Create container apps environment<br /> - Create container apps

Random names are generated for the resources to avoid conflicts and ensure unique naming for testing purposes, we have transitioned to using random strings for generating resource names
#### Contents of the locals.tf file.
```hcl
resource "random_string" "resource_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  resource_group_suffix            = "rg"
  container_app_environment_suffix = "cae"
  container_app_name_suffix        = "ca"
  environment_suffix               = "t01"
  us_region_abbreviations = {
    centralus      = "cus"
    eastus         = "eus"
    eastus2        = "eus2"
    westus         = "wus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westcentralus  = "wcus"
    westus2        = "wus2"
  }
  region_abbreviation            = local.us_region_abbreviations[var.location]
  resource_group_name            = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.resource_group_suffix}-${local.environment_suffix}"
  container_app_environment_name = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.container_app_environment_suffix}-${local.environment_suffix}"
  container_app_name             = "co-${local.region_abbreviation}-tfm-${random_string.resource_name.result}-${local.container_app_name_suffix}-${local.environment_suffix}"
  container_app_environment_vars = {
    "Test" = {
      name = local.container_app_environment_name
      workload_profile = [
        {
          name                  = "Consumption",
          workload_profile_type = "Consumption",
          minimum_count         = 0,
          maximum_count         = 1
        }
      ]
    }
  }
  container_apps_vars = {
    "Test" = {
      name          = local.container_app_name
      revision_mode = "Single"
      template = {
        min_replicas = 1
        max_replicas = 3
        containers = [
          {
            name   = "examplecontainerapp"
            image  = "mcr.microsoft.com/k8se/quickstart:latest"
            cpu    = 0.25
            memory = "0.5Gi"
          }
        ]
      }
      ingress = {
        target_port      = 80
        external_enabled = true

        traffic_weight = {
          latest_revision = true
          percentage      = 100
        }
        ip_security_restrictions = [
          {
            action           = "Allow"
            name             = "Allow_All"
            ip_address_range = "0.0.0.0/0"
          }
        ]
      }
    }
  }
} 
```
Create below resources for testing purposes.
####  Contents of the examples/main.tf file.
```hcl

module "rg" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
  source              = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-resourcegroup?ref=v1.0.0"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "container_app_environment" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  depends_on                     = [module.rg]
  source                         = "git::https://AMNEngineering@dev.azure.com/AMNEngineering/Terraform/_git/amn-az-tfm-container-app-environment?ref=v1.0.0"
  resource_group_name            = local.resource_group_name
  location                       = var.location
  container_app_environment_vars = local.container_app_environment_vars
  tags                           = var.tags
}

module "container_app" {
  depends_on                   = [module.container_app_environment]
  source                       = "../"
  resource_group_name          = local.resource_group_name
  container_app_environment_id = module.container_app_environment.container_app_environment_id["Test"]
  tags                         = var.tags
  container_apps               = local.container_apps_vars
}
``` 
When the Pull Request (PR) pipeline is triggered, the pipeline will first apply input validation unit tests. After successfully validating the inputs, it will proceed to create the necessary resources.   
It will deploy the resources in T01 environment with below (examples/t01.tfvars) var file.
#### Contents of the t01.tfvars file.
```hcl
location = "westus2"
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