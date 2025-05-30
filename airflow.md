# Airflow

# Installation
pip3 install apache-airflow

# Start server
airflow api-server
airflow api-server -p 8081 # open using a specific port e.g. 8081

# Start scheduler
airflow scheduler -D

# Visit server
http://localhost:8080/

# Login
Get pw from the following file:
nano simple_auth_manager_passwords.json.generated

## Current Login: 20250527
admin
Ymg6efnFrdVmZZrG

