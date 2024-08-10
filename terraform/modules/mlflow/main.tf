resource "aws_instance" "mlflow_server" {
  ami           = "ami-061e327e2d858410e"
  instance_type = "t2.micro"

  tags = {
    Name = "MLflow Server"
  }

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y python3-pip python3-venv

              # Set up MLflow server directory
              mkdir -p /home/admin/mlflow_server
              cd /home/admin/mlflow_server

              # Create and activate virtual environment
              python3 -m venv venv
              source venv/bin/activate

              # Upgrade pip and install pipenv
              pip install --upgrade pip
              pip install pipenv

              # Install MLflow using Pipenv
              pipenv install mlflow

              # Run MLflow server
              pipenv run mlflow server \
                --backend-store-uri sqlite:///mlflow.db \
                --default-artifact-root ./mlruns \
                --host 0.0.0.0 \
                --port 5000 &
              EOF

  vpc_security_group_ids = [aws_security_group.mlflow_sg.id]
  subnet_id              = var.subnet_id
}
