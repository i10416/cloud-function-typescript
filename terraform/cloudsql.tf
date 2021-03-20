resource "random_id" "db_name_suffix" {
  byte_length = 4
}
resource "google_sql_database_instance" "mysql" {
  name                = "sample-db-instance-${random_id.db_name_suffix.hex}"
  database_version    = "MYSQL_8_0"
  region              = var.DEFAULT_REGION
  deletion_protection = false

  settings {
    user_labels = {
      scheduled_instance = true
    }
    tier = "db-f1-micro"
  }
  depends_on = [
    google_project_service.computeapi
  ]
}

resource "google_sql_database" "database" {
  name      = "sample-db"
  instance  = google_sql_database_instance.mysql.name
  charset   = "utf8"
  collation = "utf8_general_ci"
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.mysql.name
  host     = "%"
  password = var.DB_PASSWORD
}