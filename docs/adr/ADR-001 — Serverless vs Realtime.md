# ADR-001: GitHub OIDC vs IAM Access Keys

## Status
Accepted

## Context
This project uses GitHub Actions (`iac-ci.yml`, `deploy.yml`, `destroy.yml`) to run Terraform formatting, validation, security scans, planning, and deployments.  
These workflows require authenticated access to AWS.  
Two authentication approaches were considered:

- IAM User with long-lived access keys stored in GitHub Secrets  
- IAM Role with GitHub OIDC federation and short-lived credentials

## Decision
Use a dedicated IAM Role (`ml-sagemaker-serverless-gha-role`) with GitHub OIDC federation instead of IAM User access keys.

The OIDC trust policy allows only this repository:
`repo:rusets/ml-sagemaker-serverless:*`

## Rationale
- Eliminates long-lived static AWS credentials  
- Short-lived STS tokens significantly reduce blast radius  
- GitHub → AWS OIDC is an AWS best practice for CI/CD  
- Access can be revoked instantly by removing the trust policy  
- Permissions are scoped to a single repo for least privilege

## Consequences

### Positive
- No need to store or rotate access keys  
- Stronger security posture (zero long-lived secrets)  
- Automatic credential lifecycle through OIDC  
- Better auditability and tighter IAM boundary  
- Works seamlessly across all project workflows

### Negative
- Requires correct setup of the OIDC trust policy  
- Slightly more complex initial configuration compared to static keys