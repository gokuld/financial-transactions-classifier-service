variable "vpc_id" {
  description = "The id of the VPC to deploy MLFlow to."
}

variable "subnet_id" {
  description = "The id of the subnet to deploy MLFlow to."
}

variable "mlflow_artifact_store_s3_bucket_name" {
  type = string
}

variable "mlflow_artifact_store_s3_bucket_key" {
  type    = string
  default = "mlflow-artifacts"
}
