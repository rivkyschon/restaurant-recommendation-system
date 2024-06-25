variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "environment_name" {
  description = "The name of the azd environment to be deployed"
  type        = string
}

variable "principal_id" {
  description = "The Id of the azd service principal to add to deployed keyvault access policies"
  type        = string
  default     = ""
}

variable "docker_registry_url" {
  description = "The URL of the Docker registry."
  type        = string
}

variable "docker_image_tag" {
  description = "The tag of the docker image to be deployed"
  type        = string
  default     = "latest"
}

variable "docker_image_name" {
  description = "The name of the docker image to be deployed"
  type        = string
}
