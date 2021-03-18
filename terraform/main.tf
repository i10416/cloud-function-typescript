variable "GOOGLE_CREDENTIALS_PATH" {}
variable "PROJECT_ID" {}
variable "DEFAULT_REGION" {}
variable "DB_PASSWORD" {}


resource "google_cloudfunctions_function" "scheduled_function" {
  region                = var.DEFAULT_REGION
  name                  = "sample-scheduled-function"
  description           = "sample scheduled pubsub trigger function"
  runtime               = "nodejs14"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  labels = {

  }
  environment_variables = {

  }
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.sample_topic.name
  }
  # timeout               = 60
  entry_point = "helloPubSubSubscriber"
}



resource "google_cloudfunctions_function" "http_function" {
  region                = var.DEFAULT_REGION
  name                  = "my-http-function"
  description           = "sample http trigger function"
  runtime               = "nodejs14"
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  # timeout               = 60
  trigger_http = true
  entry_point  = "helloHTTPFunction"
}