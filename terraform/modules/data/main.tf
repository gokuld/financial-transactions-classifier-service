provider "aws" {
  region = var.aws_region
}

# Create the S3 bucket for the project
resource "aws_s3_bucket" "product_categorize_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "product_categorize_bucket_versioning" {
  bucket = aws_s3_bucket.product_categorize_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule to expire non-current bucket versions after 20 days
resource "aws_s3_bucket_lifecycle_configuration" "product_categorize_bucket_lifecycle" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.product_categorize_bucket_versioning]

  bucket = aws_s3_bucket.product_categorize_bucket.bucket

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 20
    }
  }
}

# Enable server-side encryption using S3-managed keys (SSE-S3)

# Ignore the Trivy warning about encryption with customer managed
# keys. We are using S3 managed keys for now.
#trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "product_categorize_bucket_encryption" {
  bucket = aws_s3_bucket.product_categorize_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = var.s3_vpc_endpoint_route_table_ids

  policy = jsonencode({
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.product_categorize_bucket.bucket}/*"
      },
    ]
  })
}


resource "aws_s3_object" "dataset" {
  bucket = aws_s3_bucket.product_categorize_bucket.bucket
  key    = "data/${var.dataset_filename}"
  source = "${var.data_directory}/${var.dataset_filename}"

  depends_on = [aws_s3_bucket.product_categorize_bucket]
  etag       = filemd5("${var.data_directory}/${var.dataset_filename}")
}


resource "aws_s3_bucket_public_access_block" "product_categorize_bucket" {
  bucket = aws_s3_bucket.product_categorize_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
