# Ephemeral AWS Lambda + API Gateway (Terraform)

This repository provisions a minimal, low-cost HTTP API backed by a container-based AWS Lambda using Terraform.

**What this repo contains:**
- `terraform/`: Terraform configuration that creates an ECR repository, IAM role for Lambda, the Lambda function (container), an API Gateway HTTP API, and outputs.
- `lambda/`: Minimal Python Lambda application and `Dockerfile` for a container image.
- `.github/workflows/`: GitHub Actions workflows to build & push the container image to ECR and to run Terraform (plan/apply/destroy) using a remote S3 backend.

**High-level flow**
- Build container image (locally or via GitHub Actions) and push to ECR.
- Run Terraform (in CI or locally) to create or update Lambda and API Gateway pointing at the image.
- Use `terraform destroy` when you want to tear everything down (ephemeral usage).

**Quick local steps**
1. Configure AWS credentials and region (example PowerShell):

```powershell
$env:AWS_PROFILE = 'default'
$env:AWS_REGION = 'us-east-1'
```

2. Initialize Terraform and apply (this may create ECR and IAM first):

```powershell
cd terraform
terraform init
terraform apply -auto-approve
```

3. Build and push the Lambda image (or use the `Build and push Lambda image to ECR` workflow):

```powershell
docker build -t serveq:latest -f lambda/Dockerfile lambda
# tag and push to the ECR repo printed by `terraform output ecr_repo_url`
```

4. Re-run `terraform apply` after the image is pushed so Lambda references the pushed image.

5. Test the API endpoint (after apply):

```powershell
cd terraform
$endpoint = terraform output -raw api_endpoint
Invoke-RestMethod -Uri "$endpoint/" -Method Get
```

6. Destroy resources when done:

```powershell
cd terraform
terraform destroy -auto-approve
```

**CI (GitHub Actions) notes**
- The Terraform workflow expects a pre-created S3 bucket and DynamoDB table for remote state and locks. Set these as repository secrets: `TF_STATE_BUCKET`, `TF_STATE_DYNAMODB`, and `AWS_REGION`.
- The workflows are configured to assume an IAM role via GitHub OIDC using the `AWS_ROLE_NAME` secret. The role must:
  - Trust the GitHub OIDC provider (`token.actions.githubusercontent.com`) with audience `sts.amazonaws.com`.
  - Have permissions to manage S3/DynamoDB (state), ECR (push), Lambda, API Gateway, and CloudWatch as needed.

**Security & cost minimization**
- Use a least-privilege role for GitHub Actions; prefer `iam:PassRole` rather than letting CI create/manage IAM roles if you want tighter controls.
- Keep Lambda memory small and avoid provisioned concurrency to reduce cost.
- Remove resources with `terraform destroy` when idle.

**Troubleshooting tips**
- If OIDC role assumption fails, verify the workflow includes `permissions: id-token: write` and that the role trust policy includes a `sub` condition matching your repo.
- If Terraform fails to lock state, ensure the DynamoDB table uses a partition key named `LockID` of type `S`.
- Check Lambda logs in CloudWatch under `/aws/lambda/container-lambda` for runtime errors.

See the `terraform/` folder and `/.github/workflows/` for the exact configuration and further customization.
# Ephemeral AWS Lambda + API Gateway (Terraform)

This repo provisions a minimal, low-cost HTTP API backed by a Lambda container image using Terraform.

Key points:
- Terraform state is local (terraform.tfstate) — run Terraform locally to preserve state.
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

Cost-minimization tips:
- Use a single small Lambda and HTTP API Gateway (not REST API) — cheaper.
- No provisioned concurrency, no large memory sizes.
- Destroy resources when idle.

Precondition: remote backend (S3 bucket + DynamoDB table) must exist before running the CI Terraform workflow.

If you plan to run Terraform from GitHub Actions (recommended for no-local-state):

- Create an S3 bucket and DynamoDB table for Terraform state and locking. Use unique names (S3 bucket names are global).

Example AWS CLI commands:

```powershell
# replace names and region
aws s3api create-bucket --bucket my-unique-terraform-state-bucket --create-bucket-configuration LocationConstraint=us-east-1
aws dynamodb create-table --table-name my-terraform-lock-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

Then add these repository secrets in GitHub: `TF_STATE_BUCKET`, `TF_STATE_DYNAMODB`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`.

See `terraform/` and `.github/workflows/` for configs.
