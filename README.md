# Ephemeral AWS Lambda + API Gateway (Terraform)

This repo provisions a minimal, low-cost HTTP API backed by a Lambda container image using Terraform.

Key points:
- GitHub Actions builds and pushes the Lambda container image to ECR (manual `workflow_dispatch`).
- Deploy flow: run Terraform to create ECR and IAM, push image, then run Terraform again to create Lambda/API.

Quick start (local):

1. Configure AWS credentials in your shell (or use an AWS profile):

```powershell
$env:AWS_PROFILE = 'default'
$env:AWS_REGION = 'us-east-1'
```

2. Initialize Terraform and create initial infra (ECR, IAM, API skeleton):

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

3. Build and push the Lambda image (or use the provided GitHub Action):

```bash
# from repo root
docker build -t lambda-repo:latest -f lambda/Dockerfile lambda
# Tag and push to ECR (use terraform outputs to get repo URL), or run the GitHub Action
```

4. Re-run `terraform apply` to create the Lambda using the pushed image:

```bash
cd terraform
terraform apply -auto-approve
```

5. Destroy when done:

```bash
cd terraform
terraform destroy -auto-approve
```

Precondition: remote backend (S3 bucket + DynamoDB table) must exist before running the CI Terraform workflow.

If you plan to run Terraform from GitHub Actions:

- Create an S3 bucket and DynamoDB table for Terraform state and locking. Use unique names (S3 bucket names are global).

