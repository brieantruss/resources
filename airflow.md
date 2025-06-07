# Airflow v2.10.5

# Installation
pip install --upgrade pip

pip install apache-airflow==2.10.5

pip install apache-airflow-providers-google==10.12.0 apache-airflow-providers-cncf-kubernetes==7.11.0 # Specify provider versions compatible with Airflow 2.8.1, check Airflow docs if issues arise

pip install pyspark google-api-python-client google-auth-httplib2 google-auth-oauthlib flask_appbuilder

## Initialize the db
airflow db migrate

## Create a user
airflow users create \
    --username modulo \
    --firstname modulo \
    --lastname modulo \
    --role Admin \
    --email btruss@moduloinsights.com
# Set a strong password when prompted.

## Activate virtual environment 
cd ~/airflow/
source ~/airflow/airflow_env/bin/activate


# Start server
airflow webserver
airflow webserver -p 8081 # open using a specific port e.g. 8081

# Start scheduler and server
airflow scheduler -D && airflow webserver -p 8081

# Visit server
http://localhost:8081/

# Login
Get pw from the following file:
nano simple_auth_manager_passwords.json.generated

# Kill Processes
echo "--- Stopping Airflow services ---"
# Deactivate any active virtual environment (harmless if not active)
deactivate 2>/dev/null || true

# Kill any Airflow processes gracefully (if running as daemons)
pkill -f "airflow webserver" || true
pkill -f "airflow scheduler" || true
pkill -f "airflow celery worker" || true
pkill -f "airflow celery flower" || true

# Clean up any residual PID files (sometimes airflow processes get stuck)
rm -f ~/airflow/airflow-webserver.pid || true
rm -f ~/airflow/airflow-scheduler.pid || true
rm -f ~/airflow/airflow-worker.pid || true # Worker's PID if it creates one here

echo "Airflow services stopped."
# Check for remaining processes
ps aux | grep -e "airflow" -e "gunicorn" -e "uvicorn" | grep -v "grep" #check that nothing is running



## Current Login: 20250527
admin
Ymg6efnFrdVmZZrG

### Error: Already running on PID 9210 (or pid file '/home/briean/airflow/airflow-webserver.pid' is stale)


rm /home/briean/airflow/airflow-webserver.pid

### Activate airflow env on cluster

source ~/airflow/airflow_env/bin/activate