

#!/bin/bash



# Set the values for log_rotation_age and log_rotation_size

log_rotation_age=${LOG_ROTATION_AGE}

log_rotation_size=${LOG_ROTATION_SIZE}



# Update the PostgreSQL configuration file

sudo sed -i "s/^#log_rotation_age =.*/log_rotation_age = $log_rotation_age/" /etc/postgresql/${VERSION}/main/postgresql.conf

sudo sed -i "s/^#log_rotation_size =.*/log_rotation_size = $log_rotation_size/" /etc/postgresql/${VERSION}/main/postgresql.conf



# Restart the PostgreSQL service to apply the changes

sudo systemctl restart postgresql