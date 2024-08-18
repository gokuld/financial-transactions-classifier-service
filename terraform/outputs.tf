output "mlflow_server_public_ip" {
  value = module.mlflow.mlflow_server_public_ip
}

output "airflow_server_public_ip" {
  value = module.airflow.airflow_server_public_ip
}
