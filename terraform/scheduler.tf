resource "google_pubsub_topic" "sample_topic" {
  name = "sample_topic"
  labels = {

  }
}
resource "google_cloud_scheduler_job" "sample_scheduler" {
  name        = "sample_scheduler"
  schedule    = "0 12 * * *"
  description = "invoke event to do something at scheduled time"
  time_zone   = "Asia/Tokyo"
  retry_config {
    retry_count = 1
  }
  pubsub_target {
    topic_name = google_pubsub_topic.sample_topic.id
    data       = base64encode("{\"message\":\"xxx\",\"data\":\"xxx\"}")
  }
}