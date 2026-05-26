Once you've run the script, you can use the following SQL commands to inspect and manage your database objects:
1. Viewing Stored Functions
To see a list of all stored functions in your current database:
SHOW FUNCTION STATUS WHERE Db = 'health_stats';


To view the definition (the actual code) of a specific function:
SHOW CREATE FUNCTION get_formatted_date_from_dot_separated;


(Replace get_formatted_date_from_dot_separated with the name of the function you want to inspect.)
2. Viewing Stored Procedures
To see a list of all stored procedures in your current database:
SHOW PROCEDURE STATUS WHERE Db = 'health_stats';


To view the definition (the actual code) of a specific procedure:
SHOW CREATE PROCEDURE refresh_general_summary_for_date;


(Replace refresh_general_summary_for_date with the name of the procedure you want to inspect.)
3. Viewing Triggers
To see a list of all triggers in your current database:
SHOW TRIGGERS WHERE `Table` IN ('steps', 'sleep', 'heart_rate');


This command will list triggers associated with the steps, sleep, and heart_rate tables.
4. Dropping (Deleting) Objects
If you need to remove any of these objects (e.g., to re-create them after modifications), you can use the DROP commands:
Dropping a Function:
DROP FUNCTION IF EXISTS get_formatted_date_from_dot_separated;


Dropping a Procedure:
DROP PROCEDURE IF EXISTS refresh_general_summary_for_date;


Dropping a Trigger:
DROP TRIGGER IF EXISTS trg_steps_after_insert;


(You'll need to drop each trigger individually by its name.)
Important Note on Dropping Functions/Procedures:
When you are dropping and re-creating functions or procedures, remember to set the DELIMITER before and after the DROP and CREATE statements, just like in the original script. This is crucial because functions and procedures contain semicolons within their body, which would otherwise terminate the DROP or CREATE statement prematurely.
