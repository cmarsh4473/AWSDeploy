variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is free tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "wordpress_admin_user" {
  description = "WordPress admin username"
  type        = string
  default     = "admin"
}

variable "wordpress_admin_password" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "wordpress_admin_email" {
  description = "WordPress admin email"
  type        = string
  default     = "cmarsh4473@gmail.com"
}

variable "wordpress_db_password" {
  description = "WordPress database user password"
  type        = string
  sensitive   = true
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "site_name" {
  description = "WordPress site name/title"
  type        = string
  default     = "My WordPress Site"
}

variable "enable_https" {
  description = "Enable HTTPS with self-signed certificate (recommended to set to true)"
  type        = bool
  default     = false
}
