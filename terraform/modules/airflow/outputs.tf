output "airflow_server_public_ip" {
  value = aws_instance.airflow_instance.public_ip
}
