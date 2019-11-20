# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

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

variable "panos_hostname" {
    description = "Paloalto host to connect to"
    type = string
}

variable "panos_username" {
    description = "Paloalto service account username"
    type = string
}

variable "panos_password" {
    description = "Paloalto service account password"
    type = string
}

variable "name" {
    description = "The security rule name"
    type = string
}

variable "source_zones" {
    description = "List of source zones"
    type = list(string)
}

variable "source_addresses" {
    description = "List of source addresses"
    type = list(string)
}

variable "destination_zones" {
    description = "List of destination zones"
    type = list(string)
}

variable "applications" {
    description = "List of applications"
    type = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "position_ref" {
    description = "Position reference for rule placement"
    type = string
    default = "Deny All"
}

variable "source_users" {
    description = "List of source users"
    type = list(string)
    default = ["any"]
}

variable "hip_profiles" {
    description = "List of HIP profiles"
    type = list(string)
    default = ["any"]
}

variable "destination_addresses" {
    description = "List of destination addresses"
    type = list(string)
    default = ["any"]
}

variable "services" {
    description = "list of services"
    type = list(string)
    default = ["application-default"]
}

variable "categories" {
    description = "List of categories"
    type = list(string)
    default = ["any"]
}

variable "action" {
    description = "Action for the matched traffic. This can be allow (default), deny, drop, reset-client, reset-server, or reset-both"
    type = string
    default = "allow"
}