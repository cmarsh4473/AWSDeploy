output "wordpress_url" {
  description = "WordPress public URL"
  value       = "http://${aws_instance.wordpress.public_ip}"
}

output "wordpress_url_https" {
  description = "WordPress HTTPS URL (if enabled with self-signed cert)"
  value       = var.enable_https ? "https://${aws_instance.wordpress.public_ip}" : "Not configured"
}

output "instance_public_ip" {
  description = "Public IP of WordPress EC2 instance"
  value       = aws_instance.wordpress.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.wordpress.id
}

output "wordpress_admin_user" {
  description = "WordPress admin username"
  value       = var.wordpress_admin_user
}

output "wordpress_admin_email" {
  description = "WordPress admin email"
  value       = var.wordpress_admin_email
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i <your-key-pair.pem> ec2-user@${aws_instance.wordpress.public_ip}"
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.wordpress_sg.id
}
