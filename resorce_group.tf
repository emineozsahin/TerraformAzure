resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-emine"
    location = "${var.arm_region}"
}