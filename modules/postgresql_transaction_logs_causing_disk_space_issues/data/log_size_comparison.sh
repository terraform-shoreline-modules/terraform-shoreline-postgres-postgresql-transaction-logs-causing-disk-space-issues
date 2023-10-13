

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