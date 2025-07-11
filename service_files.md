# /etc/systemd/system/airflow-scheduler.service
[Unit]
Description=Airflow Scheduler
After=network.target postgresql.service # Add other services it depends on, e.g., your database
Wants=network.target postgresql.service # Use Wants for softer dependencies

[Service]
User=modulo
Group=modulo # Often good practice to set group as well
Type=simple
WorkingDirectory=/home/modulo/airflow # Your Airflow home directory
ExecStart=/home/modulo/airflow_env/bin/airflow scheduler # Full path to airflow executable in your venv
Restart=always
RestartSec=5s # Wait 5 seconds before restarting
StandardOutput=journal
StandardError=journal
# Environment="AIRFLOW_HOME=/home/modulo/airflow" # Uncomment if AIRFLOW_HOME isn't set in user's env or needs overriding

[Install]
WantedBy=multi-user.target


# /etc/systemd/system/airflow-webserver.service
[Unit]
Description=Airflow Webserver
After=network.target postgresql.service # Add other services it depends on
Wants=network.target postgresql.service

[Service]
User=modulo
Type=simple
WorkingDirectory=/home/modulo/airflow
ExecStart=/home/modulo/airflow/airflow_env/bin/airflow webserver --port 8081 --host 0.0.0.0
Restart=always
RestartSec=5s
StandardOutput=journal
StandardError=journal


[Install]
WantedBy=multi-user.target


