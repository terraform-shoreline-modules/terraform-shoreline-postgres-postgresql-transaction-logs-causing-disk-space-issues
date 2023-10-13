
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# PostgreSQL transaction logs causing disk space issues.
---

This incident type pertains to an issue related to PostgreSQL transaction logs. The problem occurs when the transaction logs start filling up rapidly, leading to disk space issues. The growth of transaction logs is a normal occurrence, but it needs to be managed efficiently to prevent disk space problems. If the transaction logs are not managed properly, it can cause issues with the database's performance, and in some cases, can even crash the database. Therefore, it's important to monitor transaction logs growth and implement appropriate measures to manage it.

### Parameters
```shell
export LOG_DIRECTORY="PLACEHOLDER"

export VERSION="PLACEHOLDER"

export LOG_ROTATION_AGE="PLACEHOLDER"

export LOG_ROTATION_SIZE="PLACEHOLDER"

export NUMBER_OF_DAYS_TO_RETAIN_LOGS="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export THRESHOLD_IN_PERCENTAGE="PLACEHOLDER"
```

## Debug

### Check disk space usage
```shell
df -h
```

### Check PostgreSQL log file location
```shell
sudo -u postgres psql -c 'SHOW log_directory;'
```

### List all PostgreSQL log files
```shell
sudo ls -lh ${LOG_DIRECTORY}
```

### Check the size of the largest PostgreSQL log file
```shell
sudo du -hs ${LOG_DIRECTORY}/*
```

### Check the current size of the PostgreSQL transaction log
```shell
sudo -u postgres psql -c 'SELECT pg_size_pretty(pg_current_xlog_location()-pg_xlog_location_diff(pg_control_checkpoint()));'
```

### Check the transaction log growth rate
```shell
sudo -u postgres psql -c 'SELECT pg_size_pretty((SELECT setting FROM pg_settings WHERE name = '\''wal_keep_segments'\'')::int * (SELECT current_setting('\''wal_segment_size'\'')::int));'
```

### Large transactions: If the database is handling large transactions, it can quickly fill up the transaction logs and cause disk space issues. This can happen if the database is used for data-intensive applications.
```shell


#!/bin/bash



# Set the variables

DATABASE=${DATABASE_NAME}

LOG_DIRECTORY=${LOG_DIRECTORY}

THRESHOLD=${THRESHOLD_IN_PERCENTAGE}



# Get the size of the transaction logs directory

logs_size=$(du -s $LOG_DIRECTORY | awk '{print $1}')



# Get the size of the database

database_size=$(psql -d $DATABASE -c "SELECT pg_database_size('$DATABASE')" | tail -3 | head -1 | awk '{print $1}')



# Calculate the percentage of transaction logs size to database size

percentage=$(echo "scale=2; $logs_size / $database_size * 100" | bc)



# Compare the percentage with the threshold

if (( $(echo "$percentage > $THRESHOLD" | bc -l) )); then

  echo "Large transactions are causing disk space issues."

else

  echo "Transaction logs are not the cause of disk space issues."

fi


```

## Repair

### Check the PostgreSQL configuration parameters related to transaction logs, such as log_rotation_age, log_rotation_size, etc., and adjust them accordingly to manage the growth of transaction logs.
```shell


#!/bin/bash



# Set the values for log_rotation_age and log_rotation_size

log_rotation_age=${LOG_ROTATION_AGE}

log_rotation_size=${LOG_ROTATION_SIZE}



# Update the PostgreSQL configuration file

sudo sed -i "s/^#log_rotation_age =.*/log_rotation_age = $log_rotation_age/" /etc/postgresql/${VERSION}/main/postgresql.conf

sudo sed -i "s/^#log_rotation_size =.*/log_rotation_size = $log_rotation_size/" /etc/postgresql/${VERSION}/main/postgresql.conf



# Restart the PostgreSQL service to apply the changes

sudo systemctl restart postgresql


```

### Purge old transaction logs periodically to free up disk space. This can be done manually or through an automated script.
```shell


#!/bin/bash



# Define variables

LOG_DIR=${LOG_DIRECTORY}

LOG_RETENTION_DAYS=${NUMBER_OF_DAYS_TO_RETAIN_LOGS}



# Purge old transaction logs

find $LOG_DIR -type f -name "*.log" -mtime +$LOG_RETENTION_DAYS -delete



# Exit script

exit 0


```