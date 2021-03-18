terraform {
  backend "gcs" {
    bucket = "terraform-state-store"
  }
}

resource "google_storage_bucket" "terraform-state-store" {
  name          = "terraform-state-store"
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