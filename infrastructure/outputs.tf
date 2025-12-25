output "gateway_public_ip" {
  description = "Public IP address of gateway"
  value       = azurerm_public_ip.pip_gateway.ip_address
}

output "gateway_private_ip" {
  description = "Private IP address of gateway"
  value       = azurerm_network_interface.nic_gateway.private_ip_address
}

output "app_private_ip" {
  description = "Private IP address of app"
  value       = azurerm_network_interface.nic_app.private_ip_address
}

output "ssh_command" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
  description = "Use this commant to get into gateway"
}
