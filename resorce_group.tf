resource "azurerm_resource_group" "terraform_sample" {
    name     = "terraform-sample"
    location = "${var.arm_region}"
}