locals {
  virtualMachineName = "VM-MultiNic"
  nicName = ["nic-1", "nic-2"]
  nicConfigName = "ipconfig1"
  virtualNetworkName = "virtualNetwork"
  addressSpace = ["10.0.0.0/16"]
  subnets = ["subnet-1", "subnet-2"]
  subnetPrefix = ["10.0.0.0/24", "10.0.1.0/24"]
  publicIPAddressName = "publicIp"
  networkSecurityGroupName = "NSG"
  networkSecurityRule = ["default-allow-rdp"]
}

resource "azurerm_resource_group" "arg-01" {
  name      = "${var.resource_group_name}"
  location  = "${var.location}"
}

resource "azurerm_virtual_network" "avn-01" {
  name = "${local.virtualNetworkName}"
  location = "${azurerm_resource_group.arg-01.location}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  address_space = "${local.addressSpace}"
}

resource "azurerm_subnet" "as-01" {
  name           = "${local.subnets[0]}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  virtual_network_name = "${azurerm_virtual_network.avn-01.name}"
  address_prefix = "${local.subnetPrefix[0]}"
}

resource "azurerm_subnet" "as-02" {
  name           = "${local.subnets[1]}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  virtual_network_name = "${azurerm_virtual_network.avn-01.name}"
  address_prefix = "${local.subnetPrefix[1]}"
}

resource "azurerm_public_ip" "apip-01" {
  name                = "${local.publicIPAddressName}"
  location            = "${azurerm_resource_group.arg-01.location}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "ansg-01" {
  name = "${local.networkSecurityGroupName}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  location = "${azurerm_resource_group.arg-01.location}"
}

resource "azurerm_network_security_rule" "ansr-01" {
  name = "${local.networkSecurityRule[0]}"
  priority = 1000
  source_address_prefix = "*"
  protocol = "Tcp"
  destination_port_range = "3389"
  access = "Allow"
  direction = "Inbound"
  source_port_range = "*"
  destination_address_prefix = "*"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  network_security_group_name = "${azurerm_network_security_group.ansg-01.name}"
}

resource "azurerm_network_interface" "ani-01" {
  name = "${local.nicName[0]}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  location = "${azurerm_resource_group.arg-01.location}"
  ip_configuration {
    name = "${local.nicConfigName}"
    subnet_id = "${azurerm_subnet.as-01.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.apip-01.id}"
  }
  network_security_group_id = "${azurerm_network_security_group.ansg-01.id}"
}

resource "azurerm_network_interface" "ani-02" {
  name = "${local.nicName[1]}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  location = "${azurerm_resource_group.arg-01.location}"
  ip_configuration {
    name = "${local.nicConfigName}"
    subnet_id = "${azurerm_subnet.as-02.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_string" "asaname-01" {
  length = 16
}

resource "azurerm_storage_account" "asa-01" {
  name = "diag${random_string.asaname-01.result}"
  resource_group_name = "${azurerm_resource_group.arg-01.name}"
  location = "${azurerm_resource_group.arg-01.location}"
  account_replication_type = "LRS"
  account_tier = "${var.storage_account_type}"
}





