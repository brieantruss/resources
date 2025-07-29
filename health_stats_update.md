# Adding a Health Sync Metric to Health Stats


## 1. Get sample file from Drive Folder

### Note the folder id 

Oxygen "1X6BX7SNdxxvs81-qJ2ALl3DU3EeD-xEL"

Blood Pressure "1TKu8AeVUnrhW_6PaSGi6womCDbWAlLGb"

vo2 Max "1HHoijUL5ma8xQc6z-W4Ty9fRbPVA2ilM"

## 2. Create table using example file

Add last_updated column to table

## 3. Create raw_files and processed_files folders

## 4. Update ETL Files

### Extract

Update folder id

Update file name regex

Update python script name

### Transform

Rename transform file for metric name

### Load

give previous version of code to gemini to update

## 5. Add files to proper directories

modulo@192.168.0.110:/home/modulo/airflow/dags/scripts/

## 6. Create DAG files

copy hs_steps and find/replace metric name in file