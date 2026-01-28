# Terraform: free-tier EC2

This folder contains Terraform configuration to create a single free-tier Amazon Linux 2 EC2 instance (t2.micro) with an HTTP endpoint.

Quick start

1. Ensure AWS credentials are available (env vars, shared config, or GitHub OIDC in CI).
2. (Optional) Provide a path to your SSH public key and pass it via `-var="public_key_path=~/.ssh/id_rsa.pub"` so Terraform creates a key pair.

Commands

```bash
cd terraform
terraform init
terraform apply -var="public_key_path=~/.ssh/id_rsa.pub" -auto-approve
```

After apply, Terraform outputs include `public_ip` and `public_dns`. The instance runs nginx (port 80).

To destroy:

```bash
terraform destroy -var="public_key_path=~/.ssh/id_rsa.pub" -auto-approve
```

Notes
- The default `instance_type` is `t2.micro` which is free-tier eligible.
- `ssh_cidr` defaults to `0.0.0.0/0`; restrict this for production.
- The repo already includes a GitHub Actions workflow that configures AWS credentials via OIDC: see `.github/workflows/main.yml`.
