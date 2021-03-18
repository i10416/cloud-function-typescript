resource "random_id" "bucket_suffix" {
  byte_length = 8
}

data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/../dist/index.zip"
}
resource "google_storage_bucket" "bucket" {
  name = "bucket-name-${random_id.bucket_suffix.hex}"
  lifecycle {
    ignore_changes = [
      name
    ]
    }
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.function_archive.output_path
}
