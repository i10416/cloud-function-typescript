provider "google" {
  credentials = file(var.GOOGLE_CREDENTIALS_PATH)
  project     = var.PROJECT_ID
  region      = var.DEFAULT_REGION
}