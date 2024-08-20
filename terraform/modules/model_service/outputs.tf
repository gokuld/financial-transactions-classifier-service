output "model_service_public_ip" {
  value = aws_instance.model_service_instance.public_ip
}
