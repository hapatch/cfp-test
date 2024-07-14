output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.app_vm.public_ip_address
}

output "registry_login_server" {
  value = azurerm_container_registry.registry.login_server
}

output "registry_admin_username" {
  value = azurerm_container_registry.registry.admin_username
}