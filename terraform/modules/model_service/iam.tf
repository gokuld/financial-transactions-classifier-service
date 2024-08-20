# Define an IAM Role for use with the model service (to load MLFlow artifacts from S3)
resource "aws_iam_role" "model_service_role" {
  name = "model_service_role"
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
#trivy:ignore:avd-aws-0057
resource "aws_iam_role_policy" "model_service_s3_policy" {
  name = "Model_Service_S3_policy"
  role = aws_iam_role.model_service_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:Get*",
        "s3:List*",
        "s3:Describe*"
      ]
      Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile to Attach the Role to the EC2 Instance
resource "aws_iam_instance_profile" "model_service_instance_profile" {
  name = "model_service_instance_profile"
  role = aws_iam_role.model_service_role.name
}
