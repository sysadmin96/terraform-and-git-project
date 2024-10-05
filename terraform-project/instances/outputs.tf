output "proxy_id" {
  value = aws_instance.proxy.id
}

output "backend_id" {
  value = aws_instance.backend.id
}
