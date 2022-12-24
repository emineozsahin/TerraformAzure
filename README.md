# Generating an Azure Virtual Machine Availability Set via Terraform

A terraform module is represented to deploy an infrastructure for an Azure Virtual Machine Availability Set in this repository.

**Availability zones** in an Azure region have their own power, networking, and cooling and are standalone from one another. Therefore, replicating the resources across the availability zones would protect the solution against any sort of outage for whatever reason.

**Azure Linux Virtual Machines**, which can be easily customized using [cloud-init](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init), in an availability set were generated with this repository.

### Purpose of Virtual Machine Availability Sets
+ Protect redundant VMs
+ Protect against underlying host failures
+ Prevent outages due to maintenance

**Fault Domain (FD):** Underlying host failure, such as power or network outages (Max FD: 3)

**Update Domain (UD):** Logical grouping of infrastructure for maintenance and updates (Max UD: 20)

## [**Terraform**](https://www.terraform.io/intro/index.html)

Terraform is an open source Infrastructure as Code (**IaC**) tool for building, changing and versioning infrastructure safely and efficiently.

The following .tf (terraform configuration file extension) files are included in this repository:

1- [**providers\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
: Azure is assigned as the provider for this infrastructure.

2- [**backend\.tf**](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
: Stores the [terraform state file](https://developer.hashicorp.com/terraform/language/state) as a Blob with the given Key within the Blob Container within [the Blob Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction). Storage account that would be used to save the terraform state file must be deployed beforehand.

3- [**variables\.tf**](https://developer.hashicorp.com/terraform/language/values/variables): contains three variables. Modify them accordingly.
- **arm-region:** The Azure datacenter region
- **arm_vm_admin_password:** Admin password for Virtual Machines
- **arm_frontend_instances:** Index number to determine how many resources to be generated.

4- [**resource_group\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group): Every resource in Azure must be placed in a resource group. Each resource can only be placed to one resource group. A resource group named terraform_example (azurerm_resource_group.terraform_sample) will be created.

5- [**vnet-subnet\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
: This file has the IaC for the following resources

 - A Virtual Network named my_vn (azurerm_virtual_network.my_vn)
  : The [Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) that the VMs use to communicate with each other and the internet.

- Subnets
: Following three subnets which are used to control network flow will be generated:
   1. A Frontend subnet named as my_subnet_frontend (azurerm_subnet.my_subnet_frontend)
   : The web servers of the service run in this subnet.

   2. A Backend subnet named as my_subnet_backend (azurerm_subnet.my_subnet_backend)
   : Application and database servers run in this completely isolated subnet.

   3. A subnet called my_subnet_dmz (azurerm_subnet.my_subnet_dmz)
   : A network security Demilitarized zone (DMZ) protects internal network resources from an untrusted network. In this repo, we generated a separate subnet which acts as a DMZ so there is no need to configure a DMZ.

In this repo, backend subnet and dmz subnet would not be connected to virtual machines. Only the front end virtual machines will be generated. There is not a Network Security Groups (NSG) but it would be nice to create a NSG for each subnet, and apply it to the subnets.

6- [**load-balancer\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb)
: Azure Load Balancer is a networking solution for distributing traffic between backend computers. A Load balancer has four elements.
- A frontend IP: Private or public endpoint for accessing the load balancing solution.
- A Backend Pool: Compute solution underlying the load balancer which is a set of VMs
- A Health Probe: probe that periodically checks the health of the backend pool to determine available nodes.
- Rules: Load balancing or NAT rules configured for allowing inbound/outbound access.

load-balancer\.tf This file has the IaC for the following resources.

- A frontend public IP (azurerm_public_ip.frontend)
- A frontend load balancer (azurerm_lb.frontend)
- An address pool for backend load balancer(azurerm_lb_backend_address_pool)
- A probe with port 80 (azurerm_lb_probe.port80) for frontend load balancer
- A load balancer rule for port 80 (azurerm_lb_rule.port80)
- A backend address pool (azurerm_lb_backend_address_pool.frontend)
- A probe with port 443 for frontend load balancer (azurerm_lb_probe.port443)
- A load balancer rule for port 443 (azurerm_lb_rule.port443)

Port-443 allows data transmission over a secured network, while Port 80 enables data transmission in plain text.

7- [**storage-account\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
: One storage account (azurerm_storage_account.frontend) will be generated.


8- [**virtual-machines\.tf**](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine):

- availability set (azurerm_availability_set.frontend)

CPU and memory, a Virtual network,a network interface and a storage account are needed to create a virtual machine.


1 - Storage containers will be generated inside the storage account for the data disks of VMs. Two containers for each Virtual Machine will be generated.
  - azurerm_storage_container.frontend[0]
  - azurerm_storage_container.frontend[1]

2 - Network Interface
- azurerm_network_interface.frontend[0]
- azurerm_network_interface.frontend[1]

3 - Ubuntu virtual machines
azurerm_virtual_machine.frontend[0]
azurerm_virtual_machine.frontend[1]


9- [**output.tf**]():Subnet IDs and Public IP address would be displayed onto the terminal screen when the terraform completes the deployment.

It is time to run the terraform.

```tf
#
terraform init

#
terraform plan

#
terraform apply
```

## **Azure Virtual Machine Scale Sets**
**Azure Virtual Machine Scale Sets** allow running Applications or hosting a Website on Azure virtual machines. A group of load-balanced VMs can be created and managed by Azure Virtual Machine Scale Sets. The number of VM instances can automatically increase or decrease in response to demand or a defined schedule.

Azure Virtual Machine Scale Sets let you create and manage a group of load balanced VMs. The number of VM instances can automatically increase or decrease in response to demand or a defined schedule. Scale sets provide the following key benefits: Easy to create and manage multiple VMs.