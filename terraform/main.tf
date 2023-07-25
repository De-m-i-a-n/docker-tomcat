# Define variables
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "existing_resource_group_name" {}
variable "existing_virtual_machine_name" {}
variable "docker_image" {}

# Configure Azure provider with the provided credentials
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# Import existing virtual machine as a data source
data "azurerm_virtual_machine" "existing_vm" {
  name                = var.existing_virtual_machine_name
  resource_group_name = var.existing_resource_group_name
}

# Create a virtual machine extension to start the Docker container
resource "azurerm_virtual_machine_extension" "start_docker_container" {
  name                 = "start-docker-container"
  virtual_machine_id   = data.azurerm_virtual_machine.existing_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    commandToExecute = "sudo docker run -d -p 8080:8080 ${var.docker_image}"
  })

  protected_settings = jsonencode({})

  depends_on = [azurerm_virtual_machine_extension.example_extension]  # If you have other extensions, add them as dependencies
}
