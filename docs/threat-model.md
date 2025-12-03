## **Threat Model — Scope**
- Purpose: Identify security risks in the ML inference pipeline
- Coverage: CloudFront, S3, API Gateway, Lambda, SageMaker Serverless, IAM, CI/CD
- Goal: Minimize attack surface for a public-facing ML API

## **System Overview (Context)**
- Public static frontend served via CloudFront
- Public API endpoint (`POST /predict`)
- Lambda proxy → SageMaker Runtime
- SageMaker Serverless hosting Mobilenet inference
- Terraform IaC manages all resources
- GitHub Actions deploys IaC and Lambda

## **Key Assets**
- **Inference API** (predict endpoint)
- **SageMaker endpoint** (model execution environment)
- **IAM roles & permissions**
- **CloudFront distribution** (public entry)
- **Terraform state** (S3 + DynamoDB)
- **GitHub OIDC role** (CI/CD permissions)
- **Lambda execution environment**

## **Threat Categories (STRIDE-Aligned)**
### **S — Spoofing**
- Risk: Unauthorized clients calling `/predict`
- Risk: CI/CD impersonation via OIDC misconfiguration
- Mitigation:
  - API keys for private usage modes (optional)
  - Strict GitHub OIDC conditions (`sub` + branch filters)

### **T — Tampering**
- Risk: Modified model artifacts or inference code
- Risk: CI or Lambda code injection
- Mitigation:
  - Version-controlled IaC (Terraform)
  - Checkov / TFSec CI scans
  - Restricted IAM roles (least privilege)

### **R — Repudiation**
- Risk: Unlogged attacker activity
- Risk: No ability to trace inference calls
- Mitigation:
  - CloudWatch logs for Lambda
  - API Gateway access logs
  - SageMaker invocation logs (optional)

### **I — Information Disclosure**
- Risk: Leaking inference results or verbose errors
- Risk: Exposing S3 bucket or CloudFront distribution
- Mitigation:
  - CORS locked to `*` only for demo (restrict for prod)
  - S3 bucket is private (CloudFront is the only access path)
  - Sanitized Lambda exception responses

### **D — Denial of Service**
- Risk: High request volume overwhelms:
  - API Gateway
  - Lambda concurrency
  - SageMaker Serverless
- Mitigation:
  - Rate limiting (API Gateway usage plans — optional)
  - MaxConcurrency = 1 for predictable cost boundaries
  - CloudFront caching for static assets

### **E — Elevation of Privilege**
- Risk: Lambda role being able to do more than invoke endpoint
- Risk: GitHub OIDC role gaining unnecessary permissions
- Mitigation:
  - Lambda → only `sagemaker:InvokeEndpoint`
  - OIDC → strict `sub: repo:rusets/ml-sagemaker-serverless:*`
  - No wildcard IAM admin privileges in Terraform

## **Threats Specific to ML Systems**
### **Model Abuse**
- Risk: Attackers using your model as free compute
- Mitigation:
  - API key (optional)
  - Per-IP throttling

### **Adversarial Inputs**
- Risk: Malformed images → crash/exception
- Mitigation:
  - Safe image decoding (`PIL.ImageFile.LOAD_TRUNCATED_IMAGES = True`)
  - Graceful error handling in inference

### **Model Drift / Corruption**
- Risk: Outdated weights or config
- Mitigation:
  - Immutable `model.tar.gz` packaging (optional)
  - Versioned deployment pipeline
  - APP_VERSION tagging

## **Residual Risks**
- Public API without authentication (by design for demo)
- No WAF layer (optional)
- No encryption-in-transit inside AWS (not needed; AWS-managed TLS)

## **Security Checklist**
- Private S3 bucket (✔)
- CloudFront-only access to static site (✔)
- IAM least privilege for Lambda (✔)
- OIDC GitHub → strict conditions (✔)
- State backend encrypted (✔)
- No secrets in code or Lambda env (✔)
- Lambda error responses sanitized (✔)