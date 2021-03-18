terraform {
  backend "gcs" {
    bucket = "sample-terraform-state-store"
  }
}

resource "google_storage_bucket" "sample-terraform-state-store" {
  name          = "sample-terraform-state-store"
  location      = var.DEFAULT_REGION
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}