resource "google_storage_bucket" "tf-bucket-526901" {
  name          = "tf-bucket-526901"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}
