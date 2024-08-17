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
