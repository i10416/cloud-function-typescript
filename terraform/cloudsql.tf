
resource "google_sql_database_instance" "mysql" {
  name             = "sample-db-instance"
  database_version = "MYSQL_8_0"
  project          = var.PROJECT_ID
  region           = var.DEFAULT_REGION

  settings {
    user_labels = {
      scheduled_instance = true
    }
    tier = "db-f1-micro"
  }
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