resource "shoreline_notebook" "postgresql_transaction_logs_causing_disk_space_issues" {
  name       = "postgresql_transaction_logs_causing_disk_space_issues"
  data       = file("${path.module}/data/postgresql_transaction_logs_causing_disk_space_issues.json")
  depends_on = [shoreline_action.invoke_transaction_logs_threshold_check,shoreline_action.invoke_update_postgresql_logging,shoreline_action.invoke_log_purge]
}

resource "shoreline_file" "transaction_logs_threshold_check" {
  name             = "transaction_logs_threshold_check"
  input_file       = "${path.module}/data/transaction_logs_threshold_check.sh"
  md5              = filemd5("${path.module}/data/transaction_logs_threshold_check.sh")
  description      = "Large transactions: If the database is handling large transactions, it can quickly fill up the transaction logs and cause disk space issues. This can happen if the database is used for data-intensive applications."
  destination_path = "/tmp/transaction_logs_threshold_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_postgresql_logging" {
  name             = "update_postgresql_logging"
  input_file       = "${path.module}/data/update_postgresql_logging.sh"
  md5              = filemd5("${path.module}/data/update_postgresql_logging.sh")
  description      = "Check the PostgreSQL configuration parameters related to transaction logs, such as log_rotation_age, log_rotation_size, etc., and adjust them accordingly to manage the growth of transaction logs."
  destination_path = "/tmp/update_postgresql_logging.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "log_purge" {
  name             = "log_purge"
  input_file       = "${path.module}/data/log_purge.sh"
  md5              = filemd5("${path.module}/data/log_purge.sh")
  description      = "Purge old transaction logs periodically to free up disk space. This can be done manually or through an automated script."
  destination_path = "/tmp/log_purge.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_transaction_logs_threshold_check" {
  name        = "invoke_transaction_logs_threshold_check"
  description = "Large transactions: If the database is handling large transactions, it can quickly fill up the transaction logs and cause disk space issues. This can happen if the database is used for data-intensive applications."
  command     = "`chmod +x /tmp/transaction_logs_threshold_check.sh && /tmp/transaction_logs_threshold_check.sh`"
  params      = ["LOG_DIRECTORY","THRESHOLD_IN_PERCENTAGE","DATABASE_NAME"]
  file_deps   = ["transaction_logs_threshold_check"]
  enabled     = true
  depends_on  = [shoreline_file.transaction_logs_threshold_check]
}

resource "shoreline_action" "invoke_update_postgresql_logging" {
  name        = "invoke_update_postgresql_logging"
  description = "Check the PostgreSQL configuration parameters related to transaction logs, such as log_rotation_age, log_rotation_size, etc., and adjust them accordingly to manage the growth of transaction logs."
  command     = "`chmod +x /tmp/update_postgresql_logging.sh && /tmp/update_postgresql_logging.sh`"
  params      = ["LOG_ROTATION_AGE","LOG_ROTATION_SIZE","VERSION"]
  file_deps   = ["update_postgresql_logging"]
  enabled     = true
  depends_on  = [shoreline_file.update_postgresql_logging]
}

resource "shoreline_action" "invoke_log_purge" {
  name        = "invoke_log_purge"
  description = "Purge old transaction logs periodically to free up disk space. This can be done manually or through an automated script."
  command     = "`chmod +x /tmp/log_purge.sh && /tmp/log_purge.sh`"
  params      = ["LOG_DIRECTORY","NUMBER_OF_DAYS_TO_RETAIN_LOGS"]
  file_deps   = ["log_purge"]
  enabled     = true
  depends_on  = [shoreline_file.log_purge]
}

