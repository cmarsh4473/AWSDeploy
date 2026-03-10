# WordPress on AWS Free Tier EC2 (Terraform)

This repository contains Terraform infrastructure as code to deploy a cost-effective WordPress site on AWS using the free tier.

## Overview

This setup runs WordPress on a **t2.micro EC2 instance** (free tier eligible) with:
- Apache web server
- PHP 8.2
- MySQL 8.0 (on the same instance to minimize costs)
- Optional self-signed SSL/TLS
- Auto-scaling configured for minimal resource usage

**Estimated Monthly Cost: ~$0-2** (within AWS free tier first 12 months)

## Prerequisites

1. **AWS Account** - with free tier eligibility
2. **Terraform** - version 1.0 or higher
3. **AWS CLI** - configured with your credentials
4. **EC2 Key Pair** - created in your AWS region for SSH access

### Create an EC2 Key Pair

```bash
# In AWS Console or via CLI:
aws ec2 create-key-pair --key-name wordpress-key --region us-east-1 \
  --query 'KeyMaterial' --output text > wordpress-key.pem
chmod 400 wordpress-key.pem
```

## Quick Start

### Option 1: Deploy via GitHub Actions (Recommended)

**Easiest for CI/CD - no local Terraform needed**

1. Set up [GitHub Secrets](./GITHUB_SECRETS_SETUP.md) with AWS credentials and passwords
2. Go to **Actions** tab in your GitHub repository
3. Select **Deploy WordPress to AWS** workflow
4. Click **Run workflow** → Choose **"plan"** → **Run workflow**
5. Review the plan, then run again with **"apply"** to deploy
6. Infrastructure creates in 2-3 minutes

See [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md) for detailed setup instructions.

### Option 2: Deploy Locally with Terraform

**More control - requires local setup**

#### 1. Initialize Terraform

```bash
cd terraform
terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="dynamodb_table=your-terraform-locks-table" \
  -backend-config="key=wordpress/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true"
```

Or, if using local state (not recommended for production):

```bash
cd terraform
terraform init
```

#### 2. Customize Variables (Optional)

Create a `terraform.tfvars` file to override defaults:

```hcl
region                      = "us-east-1"
instance_type               = "t2.micro"
wordpress_admin_user        = "admin"
wordpress_admin_password    = "YourSecurePassword123!"
wordpress_admin_email       = "your-email@example.com"
mysql_root_password         = "YourSecureMySQLPassword456!"
site_name                   = "My WordPress Blog"
enable_https                = true
```

**IMPORTANT:** Set secure passwords - don't use defaults!

#### 3. Plan and Apply

```bash
# Review what will be created
terraform plan

# Create the infrastructure
terraform apply
```

#### 4. Wait for Installation

The EC2 instance will take 2-3 minutes to complete the WordPress installation via the user data script. Monitor progress:

```bash
# Get instance ID from outputs
INSTANCE_ID=$(terraform output -raw instance_id)

# Check system logs
aws ec2 get-console-output --instance-id $INSTANCE_ID --region us-east-1
```

#### 5. Access WordPress

Once deployed, access WordPress at:

```
http://<your-public-ip>
```

The public IP is outputs by Terraform:

```bash
terraform output wordpress_url
```

## Connecting via SSH

```bash
# Use the SSH command from outputs
terraform output ssh_command

# Or manually:
ssh -i wordpress-key.pem ec2-user@<public-ip>
```

## Configuration Files

### `variables.tf`
- Define customizable inputs (region, instance type, passwords, etc.)
- Change defaults here or use `terraform.tfvars`

### `provider.tf`
- AWS provider configuration
- S3 backend configuration for state management (optional but recommended)

### `iam.tf`
- EC2 instance role and policies
- Allows EC2 to access AWS services if needed in the future

### `lambda_api.tf`
- VPC and networking (VPC, subnets, internet gateway, route tables)
- EC2 instance configuration with user data script
- Security groups for HTTP/HTTPS/SSH access

### `wordpress-setup.sh`
- Installation script run on instance startup
- Installs Apache, PHP, MySQL
- Downloads and configures WordPress
- Optionally sets up self-signed HTTPS certificate

### `outputs.tf`
- Public IP and WordPress URL
- SSH connection details
- Important configuration information

## Features

✅ **Free Tier Eligible**
- t2.micro instance (1 GB RAM guaranteed free)
- 30 GB EBS storage (free tier eligible)
- No RDS charges (MySQL on EC2)

✅ **Secure by Default**
- Security groups restrict access to necessary ports
- Optional self-signed SSL/TLS support
- MySQL password protection

✅ **Easy Management**
- Single command deployment with Terraform
- Clear outputs for accessing your site
- Infrastructure as code for version control

## First WordPress Setup

When you first visit your WordPress site, you'll see the setup wizard where you can:
1. Select your language
2. Configure WordPress with your desired title and admin credentials
3. Install WordPress

**Note:** The setup script pre-configures database credentials, so the wizard will be quick.

## Accessing WordPress Admin Panel

1. Visit `http://<public-ip>/wp-admin`
2. Login with your admin username and password
3. Configure plugins, theme, and content

## Post-Deployment

### Recommended Steps

1. **Update Passwords**
   - Change MySQL root password via SSH
   - Change WordPress admin password in wp-admin

2. **Setup Domain Name**
   - Point your domain to the instance's public IP
   - Or use Route 53 to manage DNS (small monthly cost)

3. **Enable HTTPS**
   - Set `enable_https = true` in variables
   - Use Let's Encrypt with Certbot for free SSL:
   ```bash
   ssh -i wordpress-key.pem ec2-user@<public-ip>
   sudo yum install -y certbot python3-certbot-apache
   sudo certbot certonly --apache -d yourdomain.com
   ```

4. **Backup Your Data**
   - Use AWS Backup or manual snapshots
   - Export WordPress database regularly

5. **Install Security Plugins**
   - Use Wordfence or All In One WP Security
   - Keep WordPress, plugins, and themes updated

6. **Enable Auto-Updates**
   - Configure WordPress to auto-update plugins and themes
   - Manually update WordPress core weekly

## Destroy Infrastructure

When you want to tear down the infrastructure:

```bash
terraform destroy
```

**WARNING:** This will delete your EC2 instance and all WordPress data. Create backups first if you want to keep your content.

## Cost Estimation

**Free Tier (First 12 months, if eligible):**
- EC2 t2.micro: Free
- EBS Storage (30 GB): Free
- Data transfer: Largely free (some limits apply)
- **Estimated cost: $0/month**

**After Free Tier or for m3+ micro usage:**
- t2.micro on-demand: ~$8-10/month
- EBS storage (30 GB): ~$0.30/month
- Data transfer: ~$0-2/month
- **Estimated cost: $8-12/month**

## Troubleshooting

### State Lock Issues
If you encounter "Error acquiring the state lock" errors:

1. **Check for running workflows** in GitHub Actions tab
2. **Use the Force Unlock workflow**:
   - Go to **Actions** → **Force Unlock Terraform State**
   - Click **Run workflow**
   - Enter the lock ID from the error message (e.g., `6a3b9cee-b7bf-decd-155d-b2016bea5447`)
   - Type "UNLOCK" to confirm force unlock
3. **Wait and retry** if you're unsure about force unlocking

### Instance takes too long to launch
- User data script runs on first boot (2-3 minutes)
- Check system logs: `aws ec2 get-console-output --instance-id <id>`

### Can't connect via SSH
- Ensure security group allows SSH (port 22) from your IP
- Verify key pair permissions: `chmod 400 wordpress-key.pem`
- Check that you created the key pair in the same region

### WordPress shows blank page
- Check Apache is running: `sudo systemctl status httpd`
- Review error logs: `sudo tail -f /var/log/httpd/error_log`
- Verify database connection in wp-config.php

### Database connection errors
- SSH into instance and check MySQL: `sudo mysql -u root`
- Verify credentials match wp-config.php
- Check MySQL is running: `sudo systemctl status mysqld`

## Support & Next Steps

- [WordPress Documentation](https://wordpress.org/documentation/)
- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This infrastructure is provided as-is for educational purposes.

- Create an S3 bucket and DynamoDB table for Terraform state and locking. Use unique names (S3 bucket names are global).

