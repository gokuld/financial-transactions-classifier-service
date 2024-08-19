# Define an IAM Role for use with Airflow for DAG scripts to access data files in S3
resource "aws_iam_role" "airflow_role" {
  name = "airflow_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach Policy to the IAM Role for S3 Access
resource "aws_iam_role_policy" "airflow_s3_policy" {
  name = "Airflow_S3_policy"
  role = aws_iam_role.airflow_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject"
      ]
      Resource = "arn:aws:s3:::${var.dataset_bucket_name}/${var.dataset_parquet_file_bucket_key}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.mlflow_artifact_store_s3_bucket_name}/${var.mlflow_artifact_store_s3_bucket_key}/*"
      }
    ]
  })
}

# IAM Instance Profile to Attach the Role to the EC2 Instance
resource "aws_iam_instance_profile" "airflow_instance_profile" {
  name = "airflow_instance_profile"
  role = aws_iam_role.airflow_role.name
}

resource "aws_instance" "airflow_instance" {
  ami                  = "ami-061e327e2d858410e" # Debian 12 AMI
  instance_type        = "t2.medium"
  subnet_id            = var.subnet_id
  security_groups      = [aws_security_group.airflow_sg.id]
  iam_instance_profile = aws_iam_instance_profile.airflow_instance_profile.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  # Create the destination directory for the DAG scripts
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/admin/airflow/dags/"
    ]
  }

  # File provisioner to upload the directory containing DAG scripts
  provisioner "file" {
    source      = var.dags_local_path
    destination = "/home/admin/airflow/dags/"
  }

  # Connection details for the provisioner
  connection {
    type        = "ssh"
    user        = "admin" # For Debian, the default user is often 'admin'
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y

              echo "export AIRFLOW_HOME=/home/admin/airflow" >> /home/admin/.bashrc

              # Source the updated .bashrc to load the environment variables
              source /home/admin/.bashrc

              sudo apt install -y python3-pip python3-venv libpq-dev build-essential

              # Switch to the admin user and set up Airflow
              sudo -i -u admin bash << EOL
                  # Create a virtual environment for Airflow
                  python3 -m venv /home/admin/airflow_venv
                  source /home/admin/airflow_venv/bin/activate

                  pip install -r /home/admin/airflow/dags/requirements.txt

                  # Install Airflow
                  pip install apache-airflow
                  pip install boto3 # required for mlflow to manage artifacts in S3

                  # Initialize Airflow database
                  airflow db init

                  airflow users create --role Admin \
                  --username admin --email admin \
                  --firstname admin --lastname admin \
                  --password admin

                  # Start Airflow services (webserver & scheduler)
                  nohup airflow webserver --port 8080 > /home/admin/airflow_webserver.log 2>&1 &
                  nohup airflow scheduler > /home/admin/airflow_scheduler.log 2>&1 &

                  # wait for the Airflow webserver and scheduler to be up.
                  sleep 60

                  # Set environment variables
                  airflow variables set s3_bucket '${var.dataset_bucket_name}'
                  airflow variables set s3_key '${var.dataset_parquet_file_bucket_key}'
                  airflow variables set mlflow_tracking_uri 'http://${var.mlflow_server_ip}:5000'
              EOL
              EOF

  key_name = "AirFlow Server"

  tags = {
    Name = "AirflowEC2Instance"
  }
}
