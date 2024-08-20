#trivy:ignore:avd-aws-0104 # allow egress to multiple public internet addresses.
#trivy:ignore:avd-aws-0107 # allow ingress from public internet (we do restrict the ports).
resource "aws_security_group" "model_service_sg" {
  vpc_id = var.vpc_id

  # Allow inbound traffic on BentoML model service port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
