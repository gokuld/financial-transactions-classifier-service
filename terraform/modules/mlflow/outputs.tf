output "mlflow_server_private_ip" {
  value = aws_instance.mlflow_server.private_ip
}

output "mlflow_server_public_ip" {
  value = aws_instance.mlflow_server.public_ip
}
