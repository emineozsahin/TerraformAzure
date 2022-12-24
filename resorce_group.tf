resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-example"
    location = "${var.arm_region}"
}