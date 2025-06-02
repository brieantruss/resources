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
    --username admin \
    --firstname Your \
    --lastname Name \
    --role Admin \
    --email your_email@example.com
# Set a strong password when prompted.

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
pkill -9 -f "airflow"
pkill -9 -f "gunicorn"
pkill -9 -f "uvicorn"

# Clear cache
find . -name "*.pyc" -delete
find . -name "__pycache__" -exec rm -rf {} +

# Check for remaining processes
ps aux | grep -e "airflow" -e "gunicorn" -e "uvicorn" | grep -v "grep" #check that nothing is running



## Current Login: 20250527
admin
Ymg6efnFrdVmZZrG

### Error: Already running on PID 9210 (or pid file '/home/briean/airflow/airflow-webserver.pid' is stale)


rm /home/briean/airflow/airflow-webserver.pid