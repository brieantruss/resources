# Comprehensive Airflow Cluster Setup & Pipeline Deployment on Raspberry Pi

This guide provides explicit, step-by-step instructions to set up your Airflow and PySpark cluster on Raspberry Pis, utilizing NFS for shared storage, and then deploying your existing health_stats pipeline.



## Your Setup Overview:
> 
> Four Raspberry Pis:
> 
> One Raspberry Pi 5 (Master Node): 8GB RAM, 256GB storage, running Ubuntu Server. This Pi will also serve as your primary development/management machine for Git repositories.
> 
> Three Raspberry Pi 4 Model Bs (Worker Nodes): Each with 2GB RAM, 512GB storage, running Ubuntu Server.
> 
### Core Services on Pi 5 (Master):

Airflow Webserver
Airflow Scheduler
PostgreSQL (Airflow Metadata Database)
Redis (Airflow Message Broker)
MySQL (Your Pipeline's Output Database)
Spark Master
NFS Server (for shared folders)

### Core Services on Pi 4s (Workers):

Airflow Celery Workers (execute PySpark tasks)
Spark Workers
NFS Clients (mount shared folders from Pi 5)

### Shared via NFS (sourced from Pi 5):

Airflow DAGs (.py files)
PySpark scripts (.py files)
Input Data (raw CSVs from Google Drive)
Output Data (transformed data)
Airflow Remote Logs

## Your Git Repository Strategy:

You will use two separate Git repositories to maintain a clean separation of concerns:

### airflow-cluster-infra (Your Infrastructure Repo):

Purpose: Contains all scripts and configuration needed to install and configure the Airflow and Spark infrastructure on your Raspberry Pis.
Location: You will create and manage this repo directly on your Pi 5. It will be cloned onto all other Pis for initial setup.

### health_stats (Your Existing Pipeline Code Repo):
Purpose: Contains the specific Airflow DAG (health_stats_dag.py) and PySpark scripts (extract_steps.py, transform_steps.py, load_steps.py) for your health_stats data pipeline.
Location: You will manage this existing repo directly on your Pi 5. Its relevant contents will be deployed to the NFS shared directories.


## Phase 0: Initial Git Repository Preparation (On your Raspberry Pi 5)

Before touching any other Pi, prepare your Git repositories on your Pi 5, as this will be your central management point.

### 0.1 Prepare Your Existing health_stats Repo:

Your health_stats repo's current state on your Pi 5:
~/health_stats/
├── extract_steps.py
├── gcs_key/
│   └── healthhub-425207-3fe090d13b2d.json
├── load_steps.py
├── processed_files/
│   └── steps
├── raw_files/
│   └── steps
├── README.md
├── requirements.txt
└── transform_steps.py


#### Actions to take within your ~/health_stats directory on your Pi 5:

Clean Up Generated/Output Files (Crucial for Git):
Delete processed_files/ directory:
Bash
rm -rf ~/health_stats/processed_files/


Delete raw_files/ directory:
Bash
rm -rf ~/health_stats/raw_files/


(If present) Delete __pycache__/ and *.pyc files: Ensure these are not committed. Your .gitignore (updated below) will handle this for future.
Bash
find ~/health_stats/ -type d -name "__pycache__" -exec rm -rf {} +
find ~/health_stats/ -type f -name "*.pyc" -delete


Adjust Script Locations (Highly Recommended for Clarity):
Move your PySpark scripts into a dedicated subdirectory.
Create pyspark_scripts directory:
Bash
mkdir -p ~/health_stats/pyspark_scripts


Move your existing scripts:
Bash
mv ~/health_stats/extract_steps.py ~/health_stats/pyspark_scripts/
mv ~/health_stats/transform_steps.py ~/health_stats/pyspark_scripts/
mv ~/health_stats/load_steps.py ~/health_stats/pyspark_scripts/


Create dags/ Directory and Your DAG File:
Your pipeline needs an Airflow DAG to orchestrate it.
Create dags directory:
Bash
mkdir -p ~/health_stats/dags


Create ~/health_stats/dags/health_stats_dag.py file with the following content:
(Open nano ~/health_stats/dags/health_stats_dag.py and paste the text below)
Python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG(
    dag_id='health_stats_pipeline',
    start_date=datetime(2023, 1, 1), # Adjust as needed (e.g., datetime(2025, 1, 1))
    schedule_interval=None, # Or your desired schedule (e.g., '@daily', '0 0 * * *')
    catchup=False,
    tags=['pyspark', 'health_stats'],
) as dag:
    # Define base paths relative to the NFS mounts.
    # These paths assume your 'health_stats' repo contents will be copied into
    # /srv/nfs/airflow_dags/health_stats/ on Pi5,
    # making them accessible via /mnt/airflow_dags/health_stats/ on all nodes.
    PIPELINE_BASE_PATH = "/mnt/airflow_dags/health_stats"
    PYSPARK_SCRIPTS_PATH = f"{PIPELINE_BASE_PATH}/pyspark_scripts"
    INPUT_DATA_PATH = "/mnt/airflow_data_input"
    OUTPUT_DATA_PATH = "/mnt/airflow_data_output"
    GCS_KEY_PATH = f"{PIPELINE_BASE_PATH}/gcs_key/healthhub-425207-3fe090d13b2d.json"

    # IMPORTANT: Replace <Pi5_IP_Address> with the actual IP address of your Raspberry Pi 5.
    SPARK_MASTER_URL = "spark://<Pi5_IP_Address>:7077"

    extract_task = BashOperator(
        task_id='run_extract_pyspark',
        bash_command=f'spark-submit --master {SPARK_MASTER_URL} --executor-memory 512m --driver-memory 512m {PYSPARK_SCRIPTS_PATH}/extract_steps.py',
        env={'GOOGLE_APPLICATION_CREDENTIALS': GCS_KEY_PATH} # Pass the GCS key file path via environment variable
    )

    transform_task = BashOperator(
        task_id='run_transform_pyspark',
        bash_command=f'spark-submit --master {SPARK_MASTER_URL} --executor-memory 512m --driver-memory 512m {PYSPARK_SCRIPTS_PATH}/transform_steps.py',
    )

    load_task = BashOperator(
        task_id='run_load_pyspark',
        bash_command=f'spark-submit --master {SPARK_MASTER_URL} --executor-memory 512m --driver-memory 512m {PYSPARK_SCRIPTS_PATH}/load_steps.py',
    )

    extract_task >> transform_task >> load_task

(Save and exit nano: Ctrl+O, Enter, Ctrl+X)
Rename requirements.txt to requirements-pipeline.txt:
This clarifies its purpose for this specific pipeline's Python dependencies.
Bash
mv ~/health_stats/requirements.txt ~/health_stats/requirements-pipeline.txt


Edit ~/health_stats/requirements-pipeline.txt: Ensure it lists all Python packages (including pyspark, google-api-python-client, pandas, mysql-connector-python, etc.) that your extract_steps.py, transform_steps.py, or load_steps.py scripts directly import and rely upon.
Update ~/health_stats/.gitignore:
Open nano ~/health_stats/.gitignore and ensure its content is:
Code snippet
# Python generated files
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# Virtual environments (if created locally for pipeline dev)
env/
venv/

# Airflow specific generated files (robustness, typically from infra repo)
.airflow/
# airflow.cfg
# airflow.db
logs/
webserver_config.py

# Local data/output directories (these will be NFS mounts on the cluster)
# These folders might be created during local testing, but are excluded from Git.
raw_files/
processed_files/

# Acknowledged: GCS Key - Retained in Git as per your decision for simplicity.
# This file *will be committed*. Be aware of the security implications for production.
# If you later decide to exclude it: add `gcs_key/` here and perform a git history scrub.

(Save and exit nano)
Commit and Push Changes to GitHub:
Bash
cd ~/health_stats
git add .
git commit -m "Refactor health_stats repo: Added dags/, pyspark_scripts/, updated .gitignore and requirements-pipeline.txt. Retaining gcs_key for simplicity."
git push origin main # Or your default branch name

Important: Confirm that the health_stats repo on GitHub now reflects this structure.
0.2 Prepare airflow-cluster-infra Repo (Create this new repo on your Pi 5):
Create the new Git repository directory:
Bash
cd ~
mkdir airflow-cluster-infra
cd airflow-cluster-infra
git init # Initializes a new Git repo here


Create ~/airflow-cluster-infra/requirements-airflow.txt:
(Open nano ~/airflow-cluster-infra/requirements-airflow.txt and paste the text below)
apache-airflow[celery,redis,postgres,mysql]==2.9.2 --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.2/constraints-no-providers-3.8.txt"
# Ensure this constraint URL matches the Airflow version you target.

(Save and exit nano)
Create ~/airflow-cluster-infra/requirements-pyspark.txt:
This file combines all Python dependencies that any of your PySpark pipelines might need. For now, it will simply be the content of health_stats/requirements-pipeline.txt.
(Open nano ~/airflow-cluster-infra/requirements-pyspark.txt and paste the text below)
pyspark==3.5.1 # Use the Spark version you plan to install
google-api-python-client
pandas
mysql-connector-python

(Save and exit nano)
Create ~/airflow-cluster-infra/airflow.cfg.template:
This is a template for your core Airflow configuration file.
(Open nano ~/airflow-cluster-infra/airflow.cfg.template and paste the text below)
Ini, TOML
[core]
executor = CeleryExecutor
sql_alchemy_conn = postgresql+psycopg2://airflow:YOUR_AIRFLOW_DB_PASSWORD@localhost:5432/airflow
dags_folder = /mnt/airflow_dags
load_examples = False

[celery]
broker_url = redis://localhost:6379/0
result_backend = db+postgresql://airflow:YOUR_AIRFLOW_DB_PASSWORD@localhost:5432/airflow
worker_concurrency = 2 # Adjust as needed for Pi 4 RAM

[webserver]
secret_key = YOUR_SECRET_KEY_HERE

[logging]
remote_logging = True
remote_base_log_folder = /mnt/airflow_logs

(Save and exit nano)
Create ~/airflow-cluster-infra/setup_scripts/ directory and populate it with executable shell scripts:
Bash
mkdir -p ~/airflow-cluster-infra/setup_scripts


~/airflow-cluster-infra/setup_scripts/01_install_common_deps.sh:
(Open nano ~/airflow-cluster-infra/setup_scripts/01_install_common_deps.sh and paste the text below)
Bash
#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "Updating system and installing common dependencies..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv git default-libmysqlclient-dev libpq-dev nfs-common openjdk-17-jre openjdk-17-jdk # Add Java for Spark

echo "Creating Python virtual environment and setting AIRFLOW_HOME..."
# This script assumes it's run from the root of the cloned airflow-cluster-infra repo.
# We'll clone it into ~/airflow later, so `pwd` will be ~/airflow.
mkdir -p ~/airflow # Ensure this target directory exists if not created by clone
cd ~/airflow # Navigate to the directory where the repo will be cloned
python3 -m venv airflow_env
source airflow_env/bin/activate
echo "export AIRFLOW_HOME=~/airflow" >> ~/.bashrc
source ~/.bashrc

echo "Installing Airflow and PySpark common dependencies into virtual environment..."
# These requirements files are relative to the infra repo root, which will be ~/airflow
pip install --no-cache-dir -r requirements-airflow.txt
pip install --no-cache-dir -r requirements-pyspark.txt

echo "Common dependencies installed."

(Save and exit nano)
~/airflow-cluster-infra/setup_scripts/02_install_spark.sh:
(Open nano ~/airflow-cluster-infra/setup_scripts/02_install_spark.sh and paste the text below)
Bash
#!/bin/bash
set -e

SPARK_VERSION="3.5.1" # Choose your desired Spark version (e.g., 3.5.1)
HADOOP_VERSION="3"    # Spark pre-built for Hadoop 3.3 and later
SPARK_TGZ="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_TGZ}"
INSTALL_DIR="/opt"

echo "Downloading Spark ${SPARK_VERSION}..."
wget -q --show-progress ${SPARK_URL} -O /tmp/${SPARK_TGZ}

echo "Extracting Spark to ${INSTALL_DIR}..."
sudo tar -xzf /tmp/${SPARK_TGZ} -C ${INSTALL_DIR}
sudo mv ${INSTALL_DIR}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${INSTALL_DIR}/spark

echo "Setting Spark environment variables..."
echo "export SPARK_HOME=${INSTALL_DIR}/spark" | sudo tee -a /etc/profile.d/spark.sh
echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" | sudo tee -a /etc/profile.d/spark.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64" | sudo tee -a /etc/profile.d/spark.sh # Adjust if your Java path is different
echo "export PYTHONPATH=\$SPARK_HOME/python:\$PYTHONPATH" | sudo tee -a /etc/profile.d/spark.sh
echo "export PYSPARK_PYTHON=python3" | sudo tee -a /etc/profile.d/spark.sh

# Make Spark scripts executable
sudo chmod -R +x ${INSTALL_DIR}/spark/bin ${INSTALL_DIR}/spark/sbin

echo "Cleaning up..."
rm /tmp/${SPARK_TGZ}

echo "Spark ${SPARK_VERSION} installed. Re-login or 'source /etc/profile.d/spark.sh' to apply env vars."

(Save and exit nano)
~/airflow-cluster-infra/setup_scripts/03_configure_pi5_master.sh:
(Open nano ~/airflow-cluster-infra/setup_scripts/03_configure_pi5_master.sh and paste the text below)
Bash
#!/bin/bash
set -e

AIRFLOW_DB_PASSWORD="your_airflow_db_password" # <<< CHANGE THIS TO A STRONG PASSWORD!
YOUR_DB_USER="your_db_user"                     # <<< CHANGE THIS!
YOUR_DB_PASSWORD="your_db_password"             # <<< CHANGE THIS TO A STRONG PASSWORD!
WORKER_PI_IP_RANGE="192.168.1.0/24"             # <<< CHANGE THIS! E.g., your local network subnet (192.168.1.0/24) or specific IPs like 192.168.1.10,192.168.1.11

echo "Configuring NFS Server..."
sudo systemctl start nfs-kernel-server
sudo systemctl enable nfs-kernel-server

sudo mkdir -p /srv/nfs/airflow_dags
sudo mkdir -p /srv/nfs/airflow_data_input
sudo mkdir -p /srv/nfs/airflow_data_output
sudo mkdir -p /srv/nfs/airflow_logs
sudo chmod -R 777 /srv/nfs/airflow_dags /srv/nfs/airflow_data_input /srv/nfs/airflow_data_output /srv/nfs/airflow_logs
# (Security Note: 777 is highly permissive for testing. For production, define a dedicated 'airflow' user/group,
# use 'chown' and more restrictive 'chmod' (e.g., 755 or 770 with proper group ownership).)

echo "/srv/nfs/airflow_dags ${WORKER_PI_IP_RANGE}(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
echo "/srv/nfs/airflow_data_input ${WORKER_PI_IP_RANGE}(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
echo "/srv/nfs/airflow_data_output ${WORKER_PI_IP_RANGE}(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
echo "/srv/nfs/airflow_logs ${WORKER_PI_IP_RANGE}(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server
echo "NFS Server configured."

echo "Installing & Configuring PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -i -u postgres psql -c "CREATE DATABASE airflow;"
sudo -i -u postgres psql -c "CREATE USER airflow WITH PASSWORD '${AIRFLOW_DB_PASSWORD}';"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;"
echo "PostgreSQL configured."

echo "Installing & Configuring Redis..."
sudo apt install -y redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
echo "Redis configured."

echo "Installing MySQL Server..."
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
# For full security, you should run 'sudo mysql_secure_installation' manually after this script.
sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS health_stats_db;"
sudo mysql -u root -e "CREATE USER IF NOT EXISTS '${YOUR_DB_USER}'@'localhost' IDENTIFIED BY '${YOUR_DB_PASSWORD}';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON health_stats_db.* TO '${YOUR_DB_USER}'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
echo "MySQL configured."

echo "Pi 5 Master node configuration complete (except final airflow.cfg and Airflow DB init/user steps)."

(Save and exit nano. REMEMBER TO CHANGE THE PASSWORDS AND IP RANGE WITHIN THE SCRIPT!)
~/airflow-cluster-infra/setup_scripts/04_configure_pi4_worker.sh:
(Open nano ~/airflow-cluster-infra/setup_scripts/04_configure_pi4_worker.sh and paste the text below)
Bash
#!/bin/bash
set -e

PI5_IP_ADDRESS="<Pi5_IP_Address>" # <<< CHANGE THIS to your Pi 5's actual IP address!

echo "Configuring NFS Client..."
sudo mkdir -p /mnt/airflow_dags /mnt/airflow_data_input /mnt/airflow_data_output /mnt/airflow_logs

echo "${PI5_IP_ADDRESS}:/srv/nfs/airflow_dags /mnt/airflow_dags nfs defaults 0 0" | sudo tee -a /etc/fstab
echo "${PI5_IP_ADDRESS}:/srv/nfs/airflow_data_input /mnt/airflow_data_input nfs defaults 0 0" | sudo tee -a /etc/fstab
echo "${PI5_IP_ADDRESS}:/srv/nfs/airflow_data_output /mnt/airflow_data_output nfs defaults 0 0" | sudo tee -a /etc/fstab
echo "${PI5_IP_ADDRESS}:/srv/nfs/airflow_logs /mnt/airflow_logs nfs defaults 0 0" | sudo tee -a /etc/fstab

sudo mount -a # Attempt to mount all fstab entries
echo "NFS Client configured."

echo "Pi 4 Worker node configuration complete (except final airflow.cfg steps)."

(Save and exit nano. REMEMBER TO CHANGE THE PI5_IP_ADDRESS WITHIN THE SCRIPT!)
Create ~/airflow-cluster-infra/.gitignore:
(Open nano ~/airflow-cluster-infra/.gitignore and paste the text below)
Code snippet
# Python virtual environment directory
airflow_env/

# Pycache and generated Python files
__pycache__/
*.pyc
*.pyo

# Generated Airflow configuration file
airflow.cfg

# Local database files (if Airflow ever creates a sqlite DB locally, or for dev)
*.db

(Save and exit nano)
Commit and Push airflow-cluster-infra to GitHub:
Bash
cd ~/airflow-cluster-infra
git add .
git commit -m "Initial commit of Airflow Cluster Infrastructure setup files"
git branch -M main # If this is a brand new repo
git remote add origin <your-github-airflow-cluster-infra-repo-url>
git push -u origin main

Important: Confirm that the airflow-cluster-infra repo on GitHub now contains all these files.
Phase 1: Initial System & Airflow Infrastructure Setup (On ALL Raspberry Pis)
Perform these steps via SSH for each Raspberry Pi in your cluster (Pi 5, then each of the three Pi 4s).
SSH into each Pi:
Bash
ssh pi@<Pi_IP_Address>


Clone Airflow Infrastructure Repo:
This repo contains the setup scripts and requirements. We'll clone it into ~/airflow which will also become your AIRFLOW_HOME.
Bash
cd ~
git clone <your-github-airflow-cluster-infra-repo-url> airflow # Clones repo into ~/airflow
cd ~/airflow


Make Setup Scripts Executable & Run Common Dependencies Script:
Bash
chmod +x setup_scripts/*.sh # Make all scripts in the setup_scripts folder executable
./setup_scripts/01_install_common_deps.sh

This script will: update packages, install common system dependencies (like git, python3-venv, openjdk), create the ~/airflow/airflow_env virtual environment, activate it, set AIRFLOW_HOME in .bashrc, and then pip install Airflow and common PySpark Python dependencies.
Install Spark Binaries:
Bash
./setup_scripts/02_install_spark.sh

This script will download and extract the Spark binaries to /opt/spark and set necessary environment variables. After this, it's highly recommended to reconnect your SSH session (i.e., log out and log back in) or explicitly run source /etc/profile.d/spark.sh to ensure Spark environment variables are loaded for the next steps.
Phase 2: Master Node Specific Configuration (On Raspberry Pi 5 ONLY)
Perform these steps only on your Raspberry Pi 5.
SSH into Pi 5 (if not already):
Bash
ssh pi@<Pi5_IP_Address>


Navigate to Airflow Infrastructure Repo:
Bash
cd ~/airflow


Configure Master Node Specific Services (NFS Server, PostgreSQL, Redis, MySQL):
CRITICAL: Before running, ensure you have edited setup_scripts/03_configure_pi5_master.sh on your Pi 5 (as instructed in Phase 0.2) to include your actual desired passwords and IP range.
Now, execute the script:
Bash
./setup_scripts/03_configure_pi5_master.sh


(Optional but recommended: Run sudo mysql_secure_installation after the script for full MySQL hardening.)
Generate and Configure airflow.cfg:
Activate Airflow Virtual Environment:
Bash
source ~/airflow/airflow_env/bin/activate


Generate Default Config:
Bash
airflow db init # This command creates the initial ~/airflow/airflow.cfg file


Edit airflow.cfg: Open ~/airflow/airflow.cfg in a text editor:
Bash
nano ~/airflow/airflow.cfg


CRITICAL: Update the sql_alchemy_conn (for [core]) and result_backend (for [celery]) to use the your_airflow_db_password you set in 03_configure_pi5_master.sh.
CRITICAL: Generate a strong, unique secret_key for the [webserver] section. You can use an online tool or Python's secrets.token_hex(16) for this.
Verify that dags_folder is set to /mnt/airflow_dags and remote_base_log_folder is set to /mnt/airflow_logs (these should be correct if you used the template).
Example relevant sections (with placeholders you must replace):
Ini, TOML
# In ~/airflow/airflow.cfg on Pi 5
[core]
executor = CeleryExecutor
sql_alchemy_conn = postgresql+psycopg2://airflow:YOUR_AIRFLOW_DB_PASSWORD@localhost:5432/airflow
dags_folder = /mnt/airflow_dags
load_examples = False

[celery]
broker_url = redis://localhost:6379/0
result_backend = db+postgresql://airflow:YOUR_AIRFLOW_DB_PASSWORD@localhost:5432/airflow
worker_concurrency = 2 # This is for your Pi 4 workers, but scheduler needs to know.

[webserver]
secret_key = YOUR_GENERATED_STRONG_UNIQUE_SECRET_KEY

[logging]
remote_logging = True
remote_base_log_folder = /mnt/airflow_logs


(Save and exit nano: Ctrl+O, Enter, Ctrl+X)
Initialize Airflow Database & Create Admin User:
Still with airflow_env active:
Bash
airflow db migrate # Ensures all necessary Airflow tables are created/updated in PostgreSQL
airflow users create \
    --username admin \
    --firstname Pi \
    --lastname Cluster \
    --role Admin \
    --email admin@example.com
You will be prompted to set a strong password for the admin user. This user will access the Airflow UI.
Phase 3: Worker Nodes Specific Configuration (On each Raspberry Pi 4)
Perform these steps on each of your three Raspberry Pi 4 worker nodes.
SSH into each Pi 4:
Bash
ssh pi@<Pi4_IP_Address>


Navigate to Airflow Infrastructure Repo:
Bash
cd ~/airflow


Configure NFS Client:
CRITICAL: Before running, ensure you have edited setup_scripts/04_configure_pi4_worker.sh on this Pi 4 (as instructed in Phase 0.2) to include your Pi 5's actual IP address.
Now, execute the script:
Bash
./setup_scripts/04_configure_pi4_worker.sh


This will create the mount points and add entries to /etc/fstab for auto-mounting the NFS shares.
Copy airflow.cfg from Pi 5:
It's crucial that all Airflow instances (scheduler, webserver, workers) use the identical configuration.
Bash
scp pi@<Pi5_IP_Address>:~/airflow/airflow.cfg ~/airflow/airflow.cfg

This copies the correctly configured airflow.cfg from your master Pi 5 to the current Pi 4 worker.
Phase 4: Deploying Your Pipeline Code & Starting Services
4.1 Deploy health_stats Pipeline Code (On Pi 5 - Your NFS Server)
Ensure you are on Pi 5 and in its home directory:
Bash
ssh pi@<Pi5_IP_Address>
cd ~


Verify your health_stats repository is present and up-to-date:
(You performed these modifications in Phase 0.1). If you made changes on your dev machine, ensure they are pushed to GitHub and then pulled here:
Bash
cd ~/health_stats
git pull origin main # Or your default branch
cd ~ # Go back to home directory


Copy Pipeline Files to NFS Share:
This is the step that makes your DAGs, PySpark scripts, and the GCS key accessible to Airflow on all nodes via NFS.
Bash
# Create subdirectories for organization within the NFS share on Pi 5.
# This structure mirrors your Git repo's content organization.
sudo mkdir -p /srv/nfs/airflow_dags/health_stats/dags
sudo mkdir -p /srv/nfs/airflow_dags/health_stats/pyspark_scripts
sudo mkdir -p /srv/nfs/airflow_dags/health_stats/gcs_key # For the GCS key file

# Copy your DAG file
sudo cp ~/health_stats/dags/health_stats_dag.py /srv/nfs/airflow_dags/health_stats/dags/

# Copy your PySpark script files
sudo cp ~/health_stats/pyspark_scripts/extract_steps.py /srv/nfs/airflow_dags/health_stats/pyspark_scripts/
sudo cp ~/health_stats/pyspark_scripts/transform_steps.py /srv/nfs/airflow_dags/health_stats/pyspark_scripts/
sudo cp ~/health_stats/pyspark_scripts/load_steps.py /srv/nfs/airflow_dags/health_stats/pyspark_scripts/

# Copy your GCS key file (Acknowledged security compromise for simplicity)
sudo cp ~/health_stats/gcs_key/healthhub-425207-3fe090d13b2d.json /srv/nfs/airflow_dags/health_stats/gcs_key/
# OPTIONAL: Set more restrictive permissions on the key file if you can.
# This might require creating a dedicated 'airflow' user and group first.
# For now, it might be readable by all (due to 777 on parent dirs), which is less secure.
# Example (if you have an 'airflow' user/group):
# sudo chown airflow:airflow /srv/nfs/airflow_dags/health_stats/gcs_key/healthhub-425207-3fe090d13b2d.json
# sudo chmod 600 /srv/nfs/airflow_dags/health_stats/gcs_key/healthhub-425207-3fe090d13b2d.json

The health_stats_dag.py in the NFS share (accessible as /mnt/airflow_dags/health_stats/dags/health_stats_dag.py on all nodes) will now be picked up by the Airflow Scheduler.
4.2 Start Spark Services
Start Spark Master (On Pi 5):
Ensure Spark environment variables are loaded: source /etc/profile.d/spark.sh (or re-login to your SSH session).
Bash
  start-master.sh


Verify Spark Master UI: Open a web browser on your local machine and go to http://<Pi5_IP_Address>:8080. You should see the Spark Master UI.
Start Spark Workers (On each Pi 4):
Ensure Spark environment variables are loaded: source /etc/profile.d/spark.sh (or re-login).
Bash
  start-worker.sh spark://<Pi5_IP_Address>:7077


Check the Spark Master UI on Pi 5 (http://<Pi5_IP_Address>:8080) to confirm that each worker has successfully registered.
4.3 Start Airflow Services
On Pi 5 (Master Node):
Activate environment: source ~/airflow/airflow_env/bin/activate
Bash
  airflow webserver -D # Runs in daemon mode (background)
  airflow scheduler -D # Runs in daemon mode (background)
  # (Optional) Start Celery Flower for worker monitoring:
  # airflow celery flower -D


The webserver will serve the Airflow UI, and the scheduler will monitor DAGs and dispatch tasks.
On Pi 4s (Worker Nodes):
Activate environment: source ~/airflow/airflow_env/bin/activate
Bash
  airflow celery worker -D # Runs in daemon mode (background)


These workers will wait for tasks dispatched by the Airflow scheduler on Pi 5.
5. Verification and Monitoring
Access Airflow UI: Open a web browser on your local machine and navigate to http://<IP_of_your_Pi5>:8080 (Airflow's default webserver port).
Log In: Use the admin username and the password you set during the airflow users create step.
Check DAGs: You should now see your health_stats_pipeline DAG listed in the Airflow UI.
Trigger Pipeline: Manually trigger the health_stats_pipeline DAG from the UI.
Monitor Execution: Observe the task execution in the Airflow UI. Check task logs if any tasks fail to diagnose issues. You can also monitor Spark jobs via the Spark Master UI (http://<Pi5_IP_Address>:8080).
This comprehensive guide should provide you with a clear, step-by-step path to set up your Airflow cluster and deploy your PySpark pipeline with minimal confusion. Good luck!
Sources
1. https://github.com/PushpneetSingh/State-Fiscal-Data-Explorer
2. https://github.com/Jtop13/Coding-Examples
3. https://github.com/mdeghady/twitter-sentiments

echo "--- Stopping Spark services ---"
# Kill Spark Master (if this node is the master)
pkill -f "org.apache.spark.deploy.master.Master" || true
# Kill Spark Worker (if this node is a worker)
pkill -f "org.apache.spark.deploy.worker.Worker" || true
# Kill any active spark-submit jobs or PySpark processes
pkill -f "spark-submit" || true
pkill -f "pyspark" || true
pkill -f "python.*spark" || true

echo "Spark services stopped."
