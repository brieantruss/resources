
# DOWNLOAD AND INSTALL

## Download

https://archive.apache.org/dist/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz

## Copy From One Machine to Another

scp /home/briean/Downloads/spark-3.5.5-bin-hadoop3.tgz modulo@192.168.0.110:/home/modulo

## Create Spark directory in Target machine's home directory

sudo mkdir spark

## Copy to Target folder

sudo mv spark-3.5.5-bin-hadoop3.tgz /opt/spark

## Go to Target Directory

cd /opt/spark

## Extract

sudo tar -zxvf spark-3.5.5-bin-hadoop3.tgz -C /opt/spark


# ENVIRONMENT SETUP

## Set environment variables

#### on host

export SPARK_MASTER_HOST=$(hostname -f)

cd  /opt/spark/spark-3.5.5-bin-hadoop3/conf

nano spark-env.sh.template

### Add the following to the bottom of the file

#### on host

export SPARK_LOCAL_IP=192.168.0.110 

spark.master spark://192.168.0.110:7077
spark.driver.host 192.168.0.110
spark.driver.bindAddress 192.168.0.110

export SPARK_MASTER_HOST=192.168.0.110 

#### on workers

cd  /opt/spark/spark-3.5.5-bin-hadoop3/conf

nano spark-env.sh.template

##### add to bottom of file

export SPARK_MASTER_URL=spark://192.168.0.110:7077 

save as spark-env.sh


### Edit spark-defaults

nano spark-defaults.conf.template

#### on host

export SPARK_MASTER_HOST=192.168.0.110 # on host
spark.master spark://192.168.0.110:7077
spark.driver.host 192.168.0.110
spark.driver.bindAddress 192.168.0.110

#### on workers

spark.worker.memory 500mb # on workers
spark.worker.cores 4 # on workers
spark.master spark://192.168.0.110:7077
spark.worker.ui.port 8080

### Start host

cd  /opt/spark/spark-3.5.5-bin-hadoop3/sbin
./start-master.sh

### Start Worker

cd  /opt/spark/spark-3.5.5-bin-hadoop3/sbin
./start-worker.sh spark://192.168.0.110:7077

#### after moving spark application to location of spark install (/opt/spark/spark-3.5.5-bin-hadoop3/bin/):

/opt/spark/spark-3.5.5-bin-hadoop3/bin/spark-submit --master spark://192.168.0.110:7077 transform_steps.py

# RUNNING A JOB

cd /opt/spark/spark-3.5.5-bin-hadoop3/bin/

./spark-submit --master spark://192.168.0.110:7077 transform_steps.py

./spark-submit --master spark://192.168.0.110:7077 /home/modulo/health_stats/pyspark_scripts/extract_steps.py


./spark-submit --master spark://192.168.0.79:7077 --jars /home/modulo/mysql_test/mysql-connector-j-9.1.0.jar --num-executors 3 --executor-cores 1 wikispark_cities0.py

./spark-submit --master spark://192.168.0.79:7077 --conf "spark.driver.host=192.168.0.79" --jars /home/modulo/mysql_test/mysql-connector-j-9.1.0.jar --num-executors 3 --executor-cores 1 wikispark_cities100.py




