output "mlflow_server_url" {
  value = "http://${module.mlflow.mlflow_server_public_ip}:5000"
}

output "airflow_server_url" {
  value = "http://${module.airflow.airflow_server_public_ip}:8080"
}
