Example Scenario (Most Common Installation Method):

Let's assume you installed Spark by downloading spark-3.5.1-bin-hadoop3.tgz and extracting it to /opt/spark-3.5.1-bin-hadoop3, and then configured SPARK_HOME in ~/.bashrc.

# Stop Spark:

/opt/spark-3.5.1-bin-hadoop3/sbin/stop-all.sh

# Remove installation directory:

sudo rm -rf /opt/spark-3.5.1-bin-hadoop3

# Edit ~/.bashrc:

nano ~/.bashrc

## Delete or comment out the lines:

export SPARK_HOME=/opt/spark-3.5.1-bin-hadoop3
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin


# Apply changes:

source ~/.bashrc

# Clean up temporary files (optional):

sudo rm -rf /tmp/spark-*