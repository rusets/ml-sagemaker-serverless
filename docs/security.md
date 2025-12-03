## **Security**

This project follows strict security practices aligned with AWS serverless and IaC standards:

### **1. IAM Least Privilege**
- Lambda has **only** `sagemaker:InvokeEndpoint` for the exact ARN of the endpoint.  
- SageMaker execution role has **only ECR read-only** permissions and nothing else.  
- API Gateway → Lambda permission is scoped to a **single route** (`POST /predict`).  
- No wildcard `"*"` permissions anywhere in the infrastructure code.

### **2. Zero Hard-Coded Secrets**
- No AWS keys stored in the repository.  
- No credentials embedded in Lambda, frontend, or Terraform variables.  
- All access is done through **GitHub OIDC → STS temporary credentials**.

### **3. GitHub Actions Security**
- Uses **OIDC federation**, not long-lived access keys.  
- CI/CD role trust policy restricted to:  
  `repo:rusets/ml-sagemaker-serverless:*`  
- All workflows run Terraform validation + security scans (`tflint`, `tfsec`, `checkov`).

### **4. S3 Protection Rules**
- Terraform remote state stored in S3 with **SSE-S3 (AES-256)** encryption.  
- CloudFront origin access is restricted (frontend only).  
- No public ACLs used anywhere.

### **5. Network & Data Path Security**
- HTTPS enforced end-to-end (CloudFront → API Gateway → Lambda → SageMaker).  
- No public network access to SageMaker; only Lambda can invoke the endpoint.  
- Content-Type and CORS handled explicitly to avoid injection vectors.

### **6. Terraform Security**
- State locked via DynamoDB (prevents corruption and race conditions).  
- All Terraform files validated through:  
  - `terraform fmt`  
  - `tflint`  
  - `tfsec`  
  - `checkov`

---

This provides a complete, interview-ready security section that clearly demonstrates that  
the system is **secure, modern, and follows cloud best practices**.