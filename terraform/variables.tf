variable "vsphere_user" {
  description = "vSphere user name"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
}

variable "vsphere_server" {
  description = "vCenter server"
  type        = string
}

variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
  type        = bool
  default     = true
}

variable "ad_domain" {
  description = "Active Directory Domain to join"
  type        = string
}

variable "ad_user" {
  description = "Active Directory service account user"
  type        = string
}

variable "ad_password" {
  description = "Active Directory service account password"
  type        = string
}

variable "ad_ip" {
  description = "Active Directory domain controller IP"
  type        = string
}

variable "win_admin_password" {
  description = "Default Windows Admin password"
  type        = string
}

variable "win_product_key" {
  description = "Windows OS product license"
  type        = string
}