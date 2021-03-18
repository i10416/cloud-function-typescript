
resource "google_sql_database_instance" "mysql" {
  name             = "sample-db-instance"
  database_version = "MYSQL_8_0"
  region           = var.DEFAULT_REGION

  settings {
    user_labels = {
      scheduled_instance = true
    }
    tier = "db-f1-micro"
  }
  lifecycle {
    ignore_changes = [disk_size]
  }
}