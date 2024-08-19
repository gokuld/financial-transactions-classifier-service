variable "aws_region" {
  description = "The AWS region to deploy to."
  type        = string
}

variable "availability_zone_a" {
  description = "Availability zone for subnet a"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability zone for subnet b"
  type        = string
}


variable "mlflow_artifact_store_s3_bucket_name" {
  type = string
}
