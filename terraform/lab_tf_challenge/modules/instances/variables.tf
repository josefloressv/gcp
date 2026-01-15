variable "region" {
  type        = string
  description = "Region where resources will be created"
  default     = "us-east4"
}

variable "zone" {
  type        = string
  description = "Zone where resources will be created"
  default     = "us-east4-b"
}

variable "project_id" {
  type        = string
  description = "Project ID where resources will be created"
  default     = "qwiklabs-gcp-03-21d7e1969063"
}