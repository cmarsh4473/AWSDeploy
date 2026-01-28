output "instance_id" {
  description = "The EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address of the instance"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.web.public_dns
}

output "ssh_command" {
  description = "Example SSH command (replace private key path if needed)"
  value       = var.public_key_path != "" ? "ssh -i <path-to-private-key-for-your-public-key> ec2-user@${aws_instance.web.public_ip}" : "ssh ec2-user@${aws_instance.web.public_ip} (no key created by Terraform)"
}
