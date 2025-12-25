## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_dev_test_global_vm_shutdown_schedule.shutdown_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/dev_test_global_vm_shutdown_schedule) | resource |
| [azurerm_linux_virtual_machine.vm_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.nic_app](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface.nic_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.nsg_app](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.pip_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/resource_group) | resource |
| [azurerm_subnet.snet_app](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/subnet) | resource |
| [azurerm_subnet.snet_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.nsg_assoc_app](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.nsg_assoc_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.1.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | n/a | `string` | `"xaistrying"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"Central India"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | `"rg-homelab"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VMs | `string` | n/a | yes |
| <a name="input_vm_app_size"></a> [vm\_app\_size](#input\_vm\_app\_size) | n/a | `string` | `"Standard_B1ms"` | no |
| <a name="input_vm_gateway_size"></a> [vm\_gateway\_size](#input\_vm\_gateway\_size) | n/a | `string` | `"Standard_B2ats_v2"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | n/a | `string` | `"vnet-homelab"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_private_ip"></a> [app\_private\_ip](#output\_app\_private\_ip) | Private IP address of app |
| <a name="output_gateway_private_ip"></a> [gateway\_private\_ip](#output\_gateway\_private\_ip) | Private IP address of gateway |
| <a name="output_gateway_public_ip"></a> [gateway\_public\_ip](#output\_gateway\_public\_ip) | Public IP address of gateway |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | Use this commant to get into gateway |
