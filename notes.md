# Relevant Commands

## Reference Directory:

cd /home/briean/development/reference

## Modulo-0 Connect:

ssh modulo@192.168.0.110

## Spark Directory:

cd /opt/spark/spark-3.5.5-bin-hadoop3

## Arvig Directory:

cd /home/briean/modulo/projects/arvig

## Health Stats Directory:

cd /home/modulo/development/health_stats

cd /home/briean/development/health_stats

## DbVisualizer Directory:

cd ~/dbvis_linux_25_1_4/opt/DbVisualizer

./dbvis

# Airflow

## Airlfow Directory:

cd ~/airflow/

### Airlfow Virtual Environment Activation:

source ~/airflow/airflow_env/bin/activate

### Starting Airflow

### Kill any Airflow processes gracefully (if running as daemons)
pkill -f "airflow webserver" || true
pkill -f "airflow scheduler" || true
pkill -f "airflow celery worker" || true
pkill -f "airflow celery flower" || true

### Clean up any residual PID files (sometimes airflow processes get stuck)
rm -f ~/airflow/airflow-webserver.pid || true
rm -f ~/airflow/airflow-scheduler.pid || true
rm -f ~/airflow/airflow-worker.pid || true # Worker's PID if it creates one here

## Run Flask App

cd /home/modulo/fitness_api

nohup /home/modulo/fitness_api/fitness_api/bin/python /home/modulo/fitness_api/api_app.py > flask_api_nohup.log 2>&1 &

### Closing

ps aux | grep api_app.py

kill 

## Run Streamlit App

cd /home/modulo/fitness_streamlit_app

nohup /home/modulo/fitness_streamlit_app/fitness_streamlit_app/bin/streamlit run /home/modulo/fitness_streamlit_app/streamlit_app.py --server.port 8501 --server.enableCORS false --server.enableXsrfProtection false > streamlit_nohup.log 2>&1 &

### Closing:

ps aux | grep streamlit_app.py

kill 

## Health Stats Directory:

cd /home/modulo/development/health_stats

cd /home/briean/development/health_stats

## DbVisualizer Directory:

cd ~/dbvis_linux_25_1_4/opt/DbVisualizer

./dbvis

## Delete file contents

> filename.txt

# Virtual Environments 

## Creation

python3 -m venv .venv

## Activation

source .venv/bin/activate

## Deactivation

deactivate

## Copy previous output:

!! | xclip -selection clipboard

## Copy specific line from top of previous output:

!! | head -n 4 | tail -n 1 | xclip -selection clipboard

## Copy specific line from bottom of previous output:

!! | tail -n 4 | head -n 1 | xclip -selection clipboard

## Linux Copy Syntax:

cp /home/briean/development/health_stats/etl/transform_steps.py /home/briean/development/health_stats/

## Copy From One Machine to Another

scp /home/briean/Downloads/'Finances - Master.xlsx' modulo@192.168.0.110:/home/modulo/finances/

scp /home/briean/Downloads/'Finances  - Budget.csv' modulo@192.168.0.110:/home/modulo/finances/

scp /home/briean/Downloads/'Finances  - Income Statement.csv' modulo@192.168.0.110:/home/modulo/finances/

scp /home/briean/Downloads/'Finances  - Transactions.csv' modulo@192.168.0.110:/home/modulo/finances/

scp /home/briean/load_budget.sql modulo@192.168.0.110:/home/modulo/finances/


## Submit a Spark Job

spark-submit --master spark://192.168.0.110:7077 transform_steps.py

## Open Files with Text Editor

xdg-open your_file.txt

## Open Files with LibreOffice Calc

libreoffice --calc 'Steps 2025.01.25 Samsung Health.csv'

## Print tree structure

tree cwd



## MySQL Connection Command:

sudo mysql -u root -p

## Crontab:

### Open Crontab

sudo crontab -e

### Schedule a script (Below is for daily at 3am)

0 3 * * * /home/modulo/development/health_stats/backups/health_stats_mysql_backup.py >> /var/log/mysql_backup_python.log 2>&1

## RClone Mount:

rclone mount briean88: /home/modulo/health_hub/data  --allow-other --allow-non-empty

## Kubernetes/K3s: 

kubectl get nodes

# VirtualBox

## Starting a machine
VBoxManage startvm vm-linux-1 --type headless

## Stopping a machine
VBoxManage controlvm "vm-linux-1" acpipowerbutton

# Ansible:

## Install

sudo apt install ansible

## Creating inventory 

mkdir inventory

touch install_program.yaml

ansible-playbook -i inventory install_ssh.yaml

# Github:

## Install

sudo apt install gh

## gh auth login

https://github.com/btruss13

## common commands

gh repo create repo_name --private # creates repo
git remote add origin https://github.com/btruss13/repo_name.git
git push -u origin main                 # Push committed changes to the remote repository
git branch -m master main  # Rename branch from master to main
git clone <repository_url>  # Download a repository from GitHub
git pull origin main
git pull                   # Fetch and merge changes from the remote repository
git add .                  # Stage all changes in the current directory
git commit -m "Your commit message"  # Commit staged changes with a message
git push                   # Push committed changes to the remote repository


## Setting Git Credentials w SSH

### Generate an SSH Key Pair: If you don't have one, generate it:

ssh-keygen -t ed25519 -C "btruss@moduloinsights.com"

Add your SSH Public Key to GitHub:
Copy your public key (usually ~/.ssh/id_ed25519.pub or ~/.ssh/id_rsa.pub). You can view it with cat ~/.ssh/id_ed25519.pub.
Go to your GitHub settings (Settings -> SSH and GPG keys -> New SSH key).
Paste your public key there and give it a title.

### Change your Git Remote URL to use SSH
git remote set-url origin git@github.com:btruss13/airflow.git


# MySQL

## Displaying database size
SELECT
    table_schema AS "Database",
    SUM(data_length + index_length) / 1024 / 1024 AS "Size in MB"
FROM
    information_schema.tables
GROUP BY
    table_schema;

## selecting into a csv

SELECT *
FROM infomration_schema.columns
WHERE table_schema = 'health_stats'
INTO OUTFILE '~/development/health_stats/schema.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


#### *Command Line Index:

https://ss64.com/bash/


## To search for files and directories in the current directory

ls -a | grep "spark"


## List running services

systemctl list-units --type=service --state=running


## Stop a service	

sudo systemctl stop <service-name>	

Stops a currently running service.

## Start a service	


## sudo systemctl start <service-name>	sudo systemctl start nginx	Starts a service that is 
currently 
stopped.

## Restart a service	

sudo systemctl restart <service-name>	

Stops the service and then 
starts it again. This is common after editing a configuration file.

## Reload a service	

sudo systemctl reload <service-name>

Tells the service to re-read 
its configuration files without stopping the main process. If the service doesn't support a 
reload, the command will fail or a full restart may be required.

## Reload or Restart	

sudo systemctl reload-or-restart <service-name>	s

Attempts a 
graceful reload. If a reload is not supported, it performs a full restart.


# Check disk space usage and free space

df -h


# Installing a .deb file

sudo apt install ./file_name.deb

# Operating system details

cat /etc/os-release

# BigQuery

## Switching tabs

ctrl + alt + tab