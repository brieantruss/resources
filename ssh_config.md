# SSH SETUP:
## Network Connectivity and Host Resolution:
###  Install the SSH server:
sudo apt install openssh-server

### Start the SSH service:
sudo systemctl enable --now ssh

### Verify SSH is running:
sudo systemctl status ssh

## SSH Access:
### SSH Keygen
ssh-keygen -t rsa -b 4096
/home/briean/.ssh/id_rsa

### Pushing the key
ssh-copy-id briean@192.168.0.113 # one remote
ssh-copy-id briean@192.168.0.99 && ssh-copy-id briean@192.168.0.250 # two remotes
ssh-copy-id briean@192.168.0.106 && ssh-copy-id briean@192.168.0.107 && ssh-copy-id briean@192.168.0.108


## Privilege Escalation:
### Connecting remotely
sudo apt install sshpass
ssh briean@192.168.0.113

### Open the sudoers file
sudo visudo

### Edit the sudoers file
briean ALL=(ALL:ALL) NOPASSWD: ALL
