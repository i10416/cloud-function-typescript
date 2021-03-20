data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../functions/dist"
  output_path = "${path.module}/../dist/functions.zip"
}
resource "random_id" "function_bucket_name_suffix" {
  byte_length = 4
}
resource "google_storage_bucket" "bucket" {
  name = "sample-function-bucket-${random_id.function_bucket_name_suffix.hex}"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.function_archive.output_path
}
