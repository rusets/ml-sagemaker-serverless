# **Runbook — Destroy Not Triggered**

### **1. Purpose**
- Document steps when Terraform destroy pipeline does not run.
- Applicable to: SageMaker Serverless + Lambda + API Gateway + CloudFront + S3.

---

### **2. Trigger**
- Manual destroy workflow not visible or not executing.
- Terraform resources remain active (endpoint, config, model).

---

### **3. Checks**
- **Workflow is enabled**
  - GitHub → Settings → Actions → General → Allow all actions.
- **Workflow file exists**
  - .github/workflows/destroy.yml
- **OIDC role trust is correct**
  - Principal: token.actions.githubusercontent.com
  - Condition: correct repo and branch.
- **Terraform state is unlocked**
  - DynamoDB lock table has no active locks.
- **SageMaker endpoint state**
  - Must not be stuck in "Updating".

---

### **4. Fix**
- Re-enable Actions for the repository.
- Re-save destroy.yml (forces GitHub to re-index it).
- Validate IAM role trust policy and update if needed.
- Manually remove DynamoDB lock entry if stuck.
- If endpoint = Updating:
  - Run: `aws sagemaker wait endpoint-in-service --endpoint-name <name>`
  - Or delete endpoint manually.

---

### **5. Validation**
- Workflow appears in Actions tab.
- Workflow can be manually triggered.
- Terraform destroy removes:
  - Endpoint  
  - EndpointConfig  
  - Model  
  - Lambda permissions  
  - API integration binding
- S3/CloudFront assets removed if included.

---