resource "shoreline_notebook" "postgresql_transaction_logs_causing_disk_space_issues" {
  name       = "postgresql_transaction_logs_causing_disk_space_issues"
  data       = file("${path.module}/data/postgresql_transaction_logs_causing_disk_space_issues.json")
  depends_on = [shoreline_action.invoke_log_size_comparison,shoreline_action.invoke_change_postgresql_log_rotation_settings,shoreline_action.invoke_purge_old_logs]
}

resource "shoreline_file" "log_size_comparison" {
  name             = "log_size_comparison"
  input_file       = "${path.module}/data/log_size_comparison.sh"
  md5              = filemd5("${path.module}/data/log_size_comparison.sh")
  description      = "Large transactions: If the database is handling large transactions, it can quickly fill up the transaction logs and cause disk space issues. This can happen if the database is used for data-intensive applications."
  destination_path = "/tmp/log_size_comparison.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "change_postgresql_log_rotation_settings" {
  name             = "change_postgresql_log_rotation_settings"
  input_file       = "${path.module}/data/change_postgresql_log_rotation_settings.sh"
  md5              = filemd5("${path.module}/data/change_postgresql_log_rotation_settings.sh")
  description      = "Check the PostgreSQL configuration parameters related to transaction logs, such as log_rotation_age, log_rotation_size, etc., and adjust them accordingly to manage the growth of transaction logs."
  destination_path = "/tmp/change_postgresql_log_rotation_settings.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "purge_old_logs" {
  name             = "purge_old_logs"
  input_file       = "${path.module}/data/purge_old_logs.sh"
  md5              = filemd5("${path.module}/data/purge_old_logs.sh")
  description      = "Purge old transaction logs periodically to free up disk space. This can be done manually or through an automated script."
  destination_path = "/tmp/purge_old_logs.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_log_size_comparison" {
  name        = "invoke_log_size_comparison"
  description = "Large transactions: If the database is handling large transactions, it can quickly fill up the transaction logs and cause disk space issues. This can happen if the database is used for data-intensive applications."
  command     = "`chmod +x /tmp/log_size_comparison.sh && /tmp/log_size_comparison.sh`"
  params      = ["LOG_DIRECTORY","DATABASE_NAME","THRESHOLD_IN_PERCENTAGE"]
  file_deps   = ["log_size_comparison"]
  enabled     = true
  depends_on  = [shoreline_file.log_size_comparison]
}

resource "shoreline_action" "invoke_change_postgresql_log_rotation_settings" {
  name        = "invoke_change_postgresql_log_rotation_settings"
  description = "Check the PostgreSQL configuration parameters related to transaction logs, such as log_rotation_age, log_rotation_size, etc., and adjust them accordingly to manage the growth of transaction logs."
  command     = "`chmod +x /tmp/change_postgresql_log_rotation_settings.sh && /tmp/change_postgresql_log_rotation_settings.sh`"
  params      = ["LOG_ROTATION_SIZE","VERSION","LOG_ROTATION_AGE"]
  file_deps   = ["change_postgresql_log_rotation_settings"]
  enabled     = true
  depends_on  = [shoreline_file.change_postgresql_log_rotation_settings]
}

resource "shoreline_action" "invoke_purge_old_logs" {
  name        = "invoke_purge_old_logs"
  description = "Purge old transaction logs periodically to free up disk space. This can be done manually or through an automated script."
  command     = "`chmod +x /tmp/purge_old_logs.sh && /tmp/purge_old_logs.sh`"
  params      = ["LOG_DIRECTORY","NUMBER_OF_DAYS_TO_RETAIN_LOGS"]
  file_deps   = ["purge_old_logs"]
  enabled     = true
  depends_on  = [shoreline_file.purge_old_logs]
}

