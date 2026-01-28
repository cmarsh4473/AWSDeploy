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

Remote state (recommended)

Create an S3 bucket and DynamoDB table manually (console/CLI) and set these repository secrets so CI uses the same remote state:

- `BACKEND_S3_BUCKET` — name of the S3 bucket to hold the Terraform state (must be globally unique)
- `BACKEND_DYNAMODB_TABLE` — name of the DynamoDB table for state locking
- `BACKEND_REGION` (optional) — AWS region for the backend (defaults to `us-east-1`)

CI and `destroy` workflows will initialize Terraform with these backend settings when the secrets are present. If you do not set these secrets CI will use local ephemeral state in the runner and `destroy` may find no resources.

To migrate an existing local state to the remote backend after you create the backend resources manually:

```bash
cd terraform
terraform init -migrate-state -backend-config="bucket=YOUR_UNIQUE_BUCKET_NAME" -backend-config="key=terraform.tfstate" -backend-config="region=YOUR_REGION" -backend-config="dynamodb_table=YOUR_TABLE_NAME"
```

After migration, CI workflows that set the backend secrets will operate on the same remote state.
