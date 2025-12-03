## **Rollback of SageMaker Model / Endpoint**

### **Summary**
- A new model deployment caused degraded accuracy or increased latency.
- Need to quickly revert the SageMaker endpoint to a previous stable configuration.

### **Symptoms**
- Sudden increase in inference latency after new deploy.
- Incorrect or unstable predictions (Top-5 outputs inconsistent).
- Endpoint stuck in `Updating` or frequently flapping between states.
- Lambda proxy returning errors such as “Model error” or 500 responses.

### **Root Cause**
- New model artifact (model.tar.gz) incompatible with inference script.
- Incorrect preprocessing / normalization logic.
- Using an incorrect DLC (Deep Learning Container) image version.
- Terraform timestamped model/config creation produced a bad revision.

### **Fix**
- Identify last known good resources:
  - Previous **ModelName** (timestamped)
  - Previous **EndpointConfigName**
- Run:
  - `aws sagemaker update-endpoint --endpoint-name <endpoint> --endpoint-config-name <good-config>`
- If current endpoint is stuck:
  - Delete failing endpoint config.
  - Delete failing model revision.
- Redeploy stable revision using Terraform:
  - `terraform apply -var="model_version=<PREVIOUS_VERSION>"`

### **Verification**
- Check `aws sagemaker describe-endpoint` → Status must be `InService`.
- Send a test prediction through API Gateway → must return valid JSON.
- Confirm latency returned to expected values (CloudWatch metrics).
- Validate predictions manually via the web UI.

### **Prevention**
- Introduce manual approval for production deploys.
- Add automated smoke tests after each deploy.
- Maintain versioned model artifacts with clear naming.
- Keep model rollback instructions visible in CI/CD logs.