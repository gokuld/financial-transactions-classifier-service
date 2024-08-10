output "mlflow_server_public_ip" {
  value = aws_instance.mlflow_server.public_ip
}
