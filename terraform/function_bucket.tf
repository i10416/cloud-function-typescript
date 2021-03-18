
data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/../dist/index.zip"
}
resource "google_storage_bucket" "bucket" {
  name = "<GLOBAL_UNIQUE_BACKET_NAME>"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.function_archive.output_path
}
