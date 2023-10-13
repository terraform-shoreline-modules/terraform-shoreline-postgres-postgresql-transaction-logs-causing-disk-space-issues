

#!/bin/bash



# Define variables

LOG_DIR=${LOG_DIRECTORY}

LOG_RETENTION_DAYS=${NUMBER_OF_DAYS_TO_RETAIN_LOGS}



# Purge old transaction logs

find $LOG_DIR -type f -name "*.log" -mtime +$LOG_RETENTION_DAYS -delete



# Exit script

exit 0