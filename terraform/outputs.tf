output "instance_id" {
  description = "ID der EC2-Instanz"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "Öffentliche IP der EC2-Instanz"
  value       = aws_instance.app.public_ip
}

output "instance_public_dns" {
  description = "Öffentlicher DNS der EC2-Instanz"
  value       = aws_instance.app.public_dns
}

output "app_url" {
  description = "URL zur Spring Boot Anwendung"
  value       = "http://${aws_instance.app.public_ip}:8080"
}

output "ssh_command" {
  description = "SSH-Befehl zum Verbinden"
  value       = "ssh -i ~/.ssh/deployer-key ubuntu@${aws_instance.app.public_ip}"
}
