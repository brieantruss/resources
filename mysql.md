# Installation

sudo apt install mysql-server


# MySQL Workbench

## Download

https://dev.mysql.com/downloads/workbench/

## Set up access

### Check Users

SELECT User, Host, authentication_string FROM mysql.user;
WHERE User='root'; 

### Grant all privileges to a user

GRANT ALL PRIVILEGES ON *.* TO 'briean'@'localhost' IDENTIFIED BY 'your_new_password';
FLUSH PRIVILEGES;

### Create a user

CREATE USER 'modulo'@'%' IDENTIFIED BY 'modulo';
grant all on *.* to 'modulo';

### Exit MySQL

EXIT;


## Displaying database size

SELECT
    table_schema AS "Database",
    SUM(data_length + index_length) / 1024 / 1024 AS "Size in MB"
FROM
    information_schema.tables
GROUP BY
    table_schema;

## Describe a db

SELECT
    TABLE_SCHEMA,       -- The database name
    TABLE_NAME,         -- The table name
    COLUMN_NAME,        -- The column name
    ORDINAL_POSITION,   -- The position of the column in the table (1-based)
    COLUMN_DEFAULT,     -- The default value for the column
    IS_NULLABLE,        -- Whether the column can contain NULL values ('YES' or 'NO')
    DATA_TYPE,          -- The data type (e.g., 'int', 'varchar', 'datetime')
    CHARACTER_MAXIMUM_LENGTH, -- Max length for string types
    NUMERIC_PRECISION,  -- Precision for numeric types
    NUMERIC_SCALE,      -- Scale for numeric types
    COLUMN_TYPE,        -- The full column type string (e.g., 'varchar(255)', 'int(11) unsigned')
    COLUMN_KEY,         -- Key information (e.g., 'PRI' for Primary Key, 'UNI' for Unique, 'MUL' for Index)
    EXTRA               -- Extra information (e.g., 'auto_increment')
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'health_stats' -- Replace with your actual database name
ORDER BY
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION;