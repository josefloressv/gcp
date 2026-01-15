output "bucket_name" {
  description = "The name of the storage bucket"
  value       = google_storage_bucket.test-bucket-for-state.name
}

output "bucket_url" {
  description = "The URL of the storage bucket"
  value       = google_storage_bucket.test-bucket-for-state.url
}

output "bucket_self_link" {
  description = "The self link of the storage bucket"
  value       = google_storage_bucket.test-bucket-for-state.self_link
}

output "bucket_location" {
  description = "The location of the storage bucket"
  value       = google_storage_bucket.test-bucket-for-state.location
}
