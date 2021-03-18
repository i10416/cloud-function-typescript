resource "google_project_service" "schedulerapi" {
  project = var.PROJECT_ID
  service = "cloudscheduler.googleapis.com"
  disable_dependent_services = true
}