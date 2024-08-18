resource "aws_instance" "airflow_instance" {
  ami             = "ami-061e327e2d858410e" # Debian 12 AMI
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.airflow_sg.id]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install -y python3-pip python3-venv libpq-dev build-essential

              # Create a virtual environment for Airflow
              python3 -m venv /home/admin/airflow_venv
              source /home/admin/airflow_venv/bin/activate

              # Install Airflow
              pip install apache-airflow

              # Initialize Airflow database
              airflow db init

              airflow users create --role Admin \
              --username admin --email admin \
              --firstname admin --lastname admin \
              --password admin

              # Start Airflow services (webserver & scheduler)
              nohup airflow webserver --port 8080 > /home/admin/airflow_webserver.log 2>&1 &
              nohup airflow scheduler > /home/admin/airflow_scheduler.log 2>&1 &
              EOF

  key_name = "AirFlow Server"

  tags = {
    Name = "AirflowEC2Instance"
  }
}
