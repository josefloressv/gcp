resource "google_storage_bucket" "test-bucket-for-state" {
  name                        = var.bucket_name
  location                    = var.location
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy               = var.force_destroy
}