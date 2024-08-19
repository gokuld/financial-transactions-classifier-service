resource "aws_iam_role" "mlflow_role" {
  name = "mlflow_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy" "mlflow_policy" {
  name        = "mlflow_policy"
  description = "Policy to allow access to S3 for MLflow artifacts"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.mlflow_artifact_store_s3_bucket_name}/${var.mlflow_artifact_store_s3_bucket_key}",
          "arn:aws:s3:::${var.mlflow_artifact_store_s3_bucket_name}/${var.mlflow_artifact_store_s3_bucket_key}/*"
        ],
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.mlflow_artifact_store_s3_bucket_name}"
        ],
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "mlflow_role_policy" {
  role       = aws_iam_role.mlflow_role.name
  policy_arn = aws_iam_policy.mlflow_policy.arn
}

resource "aws_iam_instance_profile" "mlflow_instance_profile" {
  name = "mlflow_instance_profile"
  role = aws_iam_role.mlflow_role.name
}
