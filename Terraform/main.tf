# ---------------------------------------------------------------------------------------------------------------------
# DEFIINE SUPPORTED TERRAFORM VERSIONS
# Define which versions of terraform this configuration supports
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# INCLUDE THE VSPHERE PROVIDER
# The vsphere provider will be leveraged to provision vSphere virtual machines
# https://www.terraform.io/docs/providers/vsphere/index.html
# ---------------------------------------------------------------------------------------------------------------------

provider "vsphere" {
  version        = "~> 1.11"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = var.vsphere_unverified_ssl
}

# ---------------------------------------------------------------------------------------------------------------------
# INCLUDE THE ACTIVE DIRECTORY PROVIDER
# The ad provider will be leveraged to prestage computer objects in active directory
# https://github.com/GSLabDev/terraform-provider-ad
# NOTE: The Active Directory provider is a community provider and therefore not supported by Hashicorp
# ---------------------------------------------------------------------------------------------------------------------

#provider "ad" {
#  domain   = var.ad_domain
#  user     = var.ad_user
#  password = var.ad_password
#  ip       = var.ad_ip
#}

# ---------------------------------------------------------------------------------------------------------------------
# INCLUDE THE PALO ALTO NETWORKS PANOR PROVIDER
# The panos provider will be leveraged to create firewall rules for newly provisioned vms
# https://www.terraform.io/docs/providers/panos/index.html
# ---------------------------------------------------------------------------------------------------------------------

provider "panos" {
  version = "~> 1.6"

  hostname = var.panos_hostname
  username = var.panos_username
  password = var.panos_password
}

module "ahead002-dmz" {
  #source = "git::ssh://git@github.com:443/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.3"
  #source = "git::ssh://git@github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.4"
  #source = "git::github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.4"
  source  = "usazpfdterra01.am.jllnet.com/Test-prod/windows-vm/vsphere"
  version = "1.0.5"

  #ad_ou                     = "OU=Virtual Servers,OU=Servers,DC=AM,DC=JLLNET,DC=com"
  vsphere_datacenter        = "Lisle_Lab"
  vsphere_cluster           = "LAB General"
  vsphere_network           = "10.30.68.x_VLAN-630"
  vsphere_datastore         = "App Data 1"
  vsphere_vm_name           = "ahead002-dmz"
  vsphere_template          = "LAC Template - Windows Server 2016"
  vsphere_ipv4_address      = "10.30.68.20"
  vsphere_ipv4_netmask      = 24
  vsphere_ipv4_gateway      = "10.30.68.1"
  vsphere_dns_server_list   = ["10.20.1.204", "10.20.1.205"]
  vsphere_disk_label        = "disk"
  vsphere_additional_disks  = [{ unit_number = 2, size = 50, thin_provisioned = true }]
  win_admin_password        = var.win_admin_password
  win_join_domain           = var.ad_domain
  win_domain_admin_user     = var.ad_user
  win_domain_admin_password = var.ad_password
  win_product_key           = var.win_product_key
  time_zone                 = "020"
}

module "ahead002-int" {
  #source = "git::ssh://git@github.com:443/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.3"
  #source = "git::ssh://git@github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.4"
  #source = "git::github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.4"
  source  = "usazpfdterra01.am.jllnet.com/Test-prod/windows-vm/vsphere"
  version = "1.0.5"

  #ad_ou                     = "OU=Virtual Servers,OU=Servers,DC=AM,DC=JLLNET,DC=com"
  vsphere_datacenter        = "Lisle_Lab"
  vsphere_cluster           = "LAB General"
  vsphere_network           = "10.30.80.x_VLAN-180"
  vsphere_datastore         = "App Data 1"
  vsphere_vm_name           = "ahead002-int"
  vsphere_template          = "LAC Template - Windows Server 2016"
  vsphere_ipv4_address      = "10.30.80.20"
  vsphere_ipv4_netmask      = 24
  vsphere_ipv4_gateway      = "10.30.80.1"
  vsphere_dns_server_list   = ["10.20.1.204", "10.20.1.205"]
  vsphere_disk_label        = "disk"
  vsphere_additional_disks  = []
  win_admin_password        = var.win_admin_password
  win_join_domain           = var.ad_domain
  win_domain_admin_user     = var.ad_user
  win_domain_admin_password = var.ad_password
  win_product_key           = var.win_product_key
  time_zone                 = "020"
}

resource "panos_security_rule_group" "example" {
  position_keyword   = "before"
  position_reference = var.position_ref
  rule {
    name                  = "Allow - 10.30.80.20 to 10.30.68.20"
    source_zones          = ["Inside"]
    source_addresses      = ["10.30.80.20"]
    source_users          = var.source_users
    hip_profiles          = var.hip_profiles
    destination_zones     = ["DMZ"]
    destination_addresses = ["10.30.68.20"]
    applications          = ["ping", "ms-rdp", "ms-ds-smb"]
    services              = var.services
    categories            = var.categories
    action                = var.action
  }
  rule {
    name                  = "Allow : 10.30.68.20 to 10.30.80.20"
    source_zones          = ["DMZ"]
    source_addresses      = ["10.30.68.20"]
    source_users          = var.source_users
    hip_profiles          = var.hip_profiles
    destination_zones     = ["Inside"]
    destination_addresses = ["10.30.80.20"]
    applications          = ["ping"]
    services              = var.services
    categories            = var.categories
    action                = var.action
  }
}