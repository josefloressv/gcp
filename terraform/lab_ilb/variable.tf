variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zone where resources will be created"
  default     = "us-central1-c"
}

variable "named_port_custom" {
  type        = string
  description = "Custom named port for backend service"
  default     = "http-python"
}

variable "enable_test_instance" {
  type        = bool
  description = "Enable creation of a test instance in the ILB lab"
  default     = false
}