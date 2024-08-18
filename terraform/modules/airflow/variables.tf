variable "vpc_id" {
  description = "The id of the VPC to deploy Airflow to."
}

variable "subnet_id" {
  description = "The id of the subnet to deploy Airflow to."
}

variable "mlflow_server_ip" {
  description = "The IP of the MLFlow server for use by Airflow DAG scripts."
}

variable "dags_local_path" {
  description = "Local path where the Airflow DAG scripts are stored. This will be copied to the Airflow instance."
  type        = string
}

variable "dataset_bucket_name" {
  description = "Name of the bucket where the dataset is stored."
  type        = string
}

variable "dataset_parquet_file_bucket_key" {
  description = "Key of the dataset file in the S3 bucket"
  type        = string
}

variable "private_key_path" {
  description = "Path of the private key used to ssh into the instance."
  type        = string
  default     = "./modules/airflow/AirFlow Server.pem"
}
