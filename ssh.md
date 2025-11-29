# SSH SETUP:
## Network Connectivity and Host Resolution:
###  Install the SSH server:
sudo apt install openssh-server

### Start the SSH service:
sudo systemctl enable --now ssh

### Verify SSH is running:
sudo systemctl status ssh
sudo systemctl status sshd

## SSH Access:
### SSH Keygen
ssh-keygen -t rsa -b 4096
/home/modulo/.ssh/id_rsa

### Pushing the key
ssh-copy-id modulo@192.168.0.110
ssh-copy-id modulo@192.168.0.111 # one remote
ssh-copy-id modulo@192.168.0.112 && ssh-copy-id modulo@192.168.0.113 # two remotes
ssh-copy-id modulo@192.168.0.110 && ssh-copy-id modulo@192.168.0.111 && ssh-copy-id modulo@192.168.0.112 && ssh-copy-id modulo@192.168.0.113


## Privilege Escalation:
### Connecting remotely
sudo apt install sshpass
ssh modulo@192.168.0.113

### Open the sudoers file
sudo visudo

### Edit the sudoers file
modulo ALL=(ALL:ALL) NOPASSWD: ALL
