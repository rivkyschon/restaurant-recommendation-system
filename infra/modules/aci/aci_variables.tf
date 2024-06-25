variable "container_group_name" {
  default       = "myContGroup"
  description   = "The name of the container group"
}

variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "dns_name_label" {
  description   = "The DNS label/name for the container groups IP"
}

variable "os_type" {
  description   = "The OS for the container group. Allowed values are Linux and Windows"
}

variable "container_name" {
  default       = "mycont01"  
  description   = "The name of the container"
}

variable "image_name" {
  description   = "The container image name"
}

variable "cpu_core_number" {
  default       = "0.5"  
  description   = "The required number of CPU cores of the containers"
}

variable "memory_size" {
  default       = "1.5"  
  description   = "The required memory of the containers in GB"
}

variable "port_number" {
  default       = "80"  
  description   = "A public port for the container"
}

variable "subnet_id" {
  description = "The ID of the subnet for the private endpoint"
  type        = string
}

variable "cosmos_connection_string" {
  description = "The connection string to the cosmsos db"
  type        = string
}
