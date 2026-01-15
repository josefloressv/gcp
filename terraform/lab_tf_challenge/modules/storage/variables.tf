variable "bucket_name" {
  description = "The name of the storage bucket (must be globally unique)"
  type        = string
}

variable "location" {
  description = "The location of the storage bucket"
  type        = string
  default     = "US"
}

variable "uniform_bucket_level_access" {
  description = "Whether to enable uniform bucket-level access"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "When deleting a bucket, delete all contained objects"
  type        = bool
  default     = false
}
