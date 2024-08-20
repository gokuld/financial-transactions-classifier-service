resource "aws_instance" "model_service_instance" {
  ami                         = "ami-061e327e2d858410e" # Debian 12 AMI
  instance_type               = "t2.small"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.model_service_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.model_service_instance_profile.name

  key_name = "Model Service"

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  # Create the destination directory for the DAG scripts
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/admin/model_service/"
    ]
  }

  # File provisioner to upload the directory containing DAG scripts
  provisioner "file" {
    source      = var.bentoml_service_source_local_path
    destination = "/home/admin/model_service"
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
              # Update and install dependencies
              sudo apt-get update
              sudo apt-get install -y python3-pip python3-venv pipenv apt-transport-https ca-certificates curl software-properties-common

              echo "export MLFLOW_TRACKING_URI='http://${var.mlflow_server_ip}:5000'" >> /home/admin/.bashrc

              # Source the updated .bashrc to load the environment variables
              source /home/admin/.bashrc

              # Switch to the admin user and set up and run the model service
              sudo -i -u admin bash << EOL
                  cd /home/admin/model_service

                  # Create a virtual environment for the model service
                  python3 -m venv /home/admin/model_service_venv
                  source /home/admin/model_service_venv/bin/activate

                  echo "MLFLOW_TRACKING_URI = \"http://${var.mlflow_server_ip}:5000\"" > config.py

                  pip install -r requirements.txt
                  bentoml serve bentoml_service.py:PredictProductCategory
              EOL
              EOF

  tags = {
    Name = "model-service-ec2-instance"
  }
}
