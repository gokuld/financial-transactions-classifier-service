terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
}

module "data" {
  source = "./modules/data"

  aws_region                      = var.aws_region
  vpc_id                          = module.network.vpc_id
  s3_vpc_endpoint_route_table_ids = [module.network.private_route_table.id]
}

module "mlflow" {
  source = "./modules/mlflow"

  vpc_id                               = module.network.vpc_id
  subnet_id                            = module.network.public_subnet_a_id
  mlflow_artifact_store_s3_bucket_name = var.mlflow_artifact_store_s3_bucket_name
}

module "airflow" {
  source = "./modules/airflow"

  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_a_id
  mlflow_server_ip = module.mlflow.mlflow_server_private_ip

  dags_local_path                 = var.airflow_dags_local_path
  dataset_bucket_name             = var.dataset_bucket_name
  dataset_parquet_file_bucket_key = var.dataset_parquet_file_bucket_key

  mlflow_artifact_store_s3_bucket_name = var.mlflow_artifact_store_s3_bucket_name
}

module "model_service" {
  source = "./modules/model_service"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_a_id

  bentoml_service_source_local_path = var.bentoml_service_source_local_path

  mlflow_server_ip                     = module.mlflow.mlflow_server_private_ip
  mlflow_artifact_store_s3_bucket_name = var.mlflow_artifact_store_s3_bucket_name

}
