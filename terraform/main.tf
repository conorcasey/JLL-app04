terraform {
  required_version = ">= 0.12"
}

provider "vsphere" {
  version        = "~> 1.11"
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = var.vsphere_unverified_ssl
}

provider "ad" {
  domain   = var.ad_domain
  user     = var.ad_user
  password = var.ad_password
  ip       = var.ad_ip
}

module "ahead001" {
  #source = "git::ssh://git@github.com:443/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.3"
  source = "git::ssh://git@github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.3"
  #source = "git::github.com/terraform-JLL/module-vsphere-windows-vm.git?ref=v1.0.3"

  ad_ou                     = "OU=Virtual Servers,OU=Servers,DC=AM,DC=JLLNET,DC=com"
  vsphere_datacenter        = "Lisle_Lab"
  vsphere_cluster           = "LAB General"
  vsphere_network           = "10.20.86.x_VLAN-86_Z-App"
  vsphere_datastore         = "App Data 1"
  vsphere_vm_name           = "ahead001"
  vsphere_template          = "LAC Template - Windows Server 2016"
  vsphere_ipv4_address      = "10.20.86.226"
  vsphere_ipv4_netmask      = 24
  vsphere_ipv4_gateway      = "10.20.86.1"
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
