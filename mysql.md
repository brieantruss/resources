# Installation


# MySQL Workbench
## Download
https://dev.mysql.com/downloads/workbench/

## Set up access
SELECT User, Host, authentication_string FROM mysql.user WHERE User='root';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'your_new_password';
FLUSH PRIVILEGES;
