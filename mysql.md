# Installation
sudo apt install mysql-server


# MySQL Workbench
## Download
https://dev.mysql.com/downloads/workbench/

## Set up access

### Check Users
SELECT User, Host, authentication_string FROM mysql.user WHERE User='root'; 

### Grant all privileges to a user
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'your_new_password';
FLUSH PRIVILEGES;

### Create a user
CREATE USER 'briean'@'%' IDENTIFIED BY 'briean';

### Exit MySQL
EXIT;
