variable "vpc_id" {
  description = "The id of the VPC to deploy Airflow to."
}

variable "subnet_id" {
  description = "The id of the subnet to deploy Airflow to."
}

variable "mlflow_server_ip" {
  description = "The IP of the MLFlow server for use by Airflow DAG scripts."
}
