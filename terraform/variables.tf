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

variable "dataset_bucket_name" {
  description = "Name of the bucket where the dataset is stored."
  type        = string
}

variable "dataset_parquet_file_bucket_key" {
  description = "Key of the dataset file in the S3 bucket"
  type        = string
  default     = "data/description-category-data-sample.parquet"
}

variable "airflow_dags_local_path" {
  description = "Local path where the Airflow DAG scripts are stored. This will be copied to the Airflow instance."
  type        = string
  default     = "../pipelines/airflow/dags/"
}

variable "bentoml_service_source_local_path" {
  description = "Local path containing the source to build and run the bentoml model service. This will be copied to the model service instance."
  type        = string
  default     = "../model_service/"
}
