output "public_ip" {
  description = "Put this in the GitHub secret EC2_HOST"
  value       = aws_eip.app.public_ip
}

output "app_url" {
  description = "Where the shop will be reachable after the first deploy"
  value       = "http://${aws_eip.app.public_ip}"
}

output "instance_id" {
  description = "Instance id (use with: aws ssm start-session --target <id>)"
  value       = aws_instance.app.id
}
