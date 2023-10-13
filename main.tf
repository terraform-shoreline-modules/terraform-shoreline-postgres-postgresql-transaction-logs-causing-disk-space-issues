terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "postgresql_transaction_logs_causing_disk_space_issues" {
  source    = "./modules/postgresql_transaction_logs_causing_disk_space_issues"

  providers = {
    shoreline = shoreline
  }
}