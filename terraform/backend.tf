terraform {
  backend "gcs" {
    bucket = "sample-terraform-state-store"
  }
}
