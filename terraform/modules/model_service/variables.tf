variable "vpc_id" {
  description = "The id of the VPC to deploy the model service to."
}

variable "subnet_id" {
  description = "The id of the subnet to deploy the model service to."
}

variable "bentoml_service_source_local_path" {
  description = "Local path containing the source to build and run the bentoml model service. This will be copied to the model service instance."
  type        = string
}

variable "private_key_path" {
  description = "Path of the private key used to ssh into the instance."
  type        = string
  default     = "./modules/model_service/Model Service.pem"
}

variable "mlflow_server_ip" {
  description = "The IP of the MLFlow server."
}

# used for adding allow PutObject policy for storing MLFlow artifacts
variable "mlflow_artifact_store_s3_bucket_name" {
  type = string
}

# used for adding allow PutObject policy for storing MLFlow artifacts
variable "mlflow_artifact_store_s3_bucket_key" {
  type    = string
  default = "mlflow-artifacts"
}
