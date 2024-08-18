#trivy:ignore:avd-aws-0104 # allow egress to multiple public internet addresses.
#trivy:ignore:avd-aws-0107 # allow ingress from public internet (we do restrict the ports).
resource "aws_security_group" "airflow_sg" {
  vpc_id = var.vpc_id
  name   = "airflow-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "airflow-security-group"
  }
}
