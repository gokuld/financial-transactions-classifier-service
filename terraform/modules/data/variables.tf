variable "aws_region" {
  description = "The AWS region to deploy to."
  type        = string
}

variable "vpc_id" {
  description = "The VPC to deploy to."
  type        = string
}

variable "s3_vpc_endpoint_route_table_ids" {
  description = "The IDs of the private route tables to associate with the VPC endpoint"
  type        = list(string)
}

variable "bucket_name" {
  description = "The name of the S3 bucket for this project."
  type        = string
  default     = "product-categorize"
}

variable "data_directory" {
  description = "The directory with the local parquet file for the dataset."
  type        = string
  default     = "../data/amazon-product-reviews/"
}

variable "dataset_filename" {
  description = "The name of the local parquet file that is the dataset."
  type        = string
  default     = "description-category-data-sample.parquet"
}
