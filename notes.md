# Relevant Commands

## Command Line Index:
https://ss64.com/bash/

## Copy previous output:
!! | xclip -selection clipboard

## Copy specific line from top of previous output:
!! | head -n 4 | tail -n 1 | xclip -selection clipboard

## Copy specific line from bottom of previous output:
!! | tail -n 4 | head -n 1 | xclip -selection clipboard

## Linux Copy Syntax:
cp /home/briean/development/health_stats/etl/transform_steps.py /home/briean/development/health_stats/

## Copy From One Machine to Another
scp /home/briean/Downloads/spark-3.5.5-bin-hadoop3.tgz briean@192.168.0.250:/home/briean

scp /home/briean/development/health_stats/transform_steps.py briean@192.168.0.245:/opt/spark/spark-3.5.5-bin-hadoop3/bin/

## Submit a Spark Job
spark-submit --master spark://192.168.0.136:7077 transform_steps.py

## Open Files with Text Editor
xdg-open your_file.txt

## Open Files with LibreOffice Calc
libreoffice --calc 'Steps 2025.01.25 Samsung Health.csv'

## Reference Directory:
cd /home/briean/development/reference

## Spark Directory:
cd /opt/spark/spark-3.5.5-bin-hadoop3

## Arvig Directory:
cd /home/briean/modulo/projects/arvig

## Health Stats Directory:
cd /home/briean/development/health_stats

# Virtual Environments 

## Creation
python3 -m venv .video_subs
python3 -m venv .health_hub_dagster

## Activation
source .gtd_media/bin/activate
source .health_stats/bin/activate

## Deactivation
deactivate

# MySQL Connection Command:
sudo mysql -u root -p

Crontab:
crontab -e

RClone Mount:
rclone mount briean88: /home/modulo/health_hub/data  --allow-other --allow-non-empty

Kubernetes/K3s: 
kubectl get nodes

# VirtualBox

## Starting a machine
VBoxManage startvm vm-linux-1 --type headless

## Stopping a machine
VBoxManage controlvm "vm-linux-1" acpipowerbutton

# Ansible:
sudo apt install ansible

mkdir inventory

touch install_program.yaml

ansible-playbook -i inventory install_ssh.yaml

# Github:

## Install
sudo apt install gh

## gh auth login
https://github.com/btruss13

## commands
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





