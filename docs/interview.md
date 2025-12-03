# INTERVIEW SUMMARY — SageMaker Serverless Mobilenet V2

## **1. Key Architecture Choices**
- **Serverless ML instead of Lambda-only:** avoids memory/time limits, faster cold starts, better scaling.
- **API Gateway → Lambda → SageMaker:** Lambda handles CORS, validation, future auth; frontend insulated from AWS internals.
- **Terraform + null_resource (CLI):** deterministic endpoint lifecycle; timestamped models; reliable update/rollback.

---

## **2. Problems Solved**
- **CloudFront stale config.js:** fixed via targeted invalidations.
- **IAM 403 (Lambda → SageMaker):** explicit `InvokeEndpoint` for precise ARN.
- **Endpoint stuck Updating/Failed:** added logic to recreate/wait until `InService`.

---

## **3. Trade-Offs**
- **Serverless ML vs containers:** lower cost/ops; higher latency OK for demo.
- **HTTP API vs REST API:** 70% cheaper and simpler; fewer advanced features.
- **CLI orchestration vs native TF:** more flexible and stable; requires AWS CLI.

---

## **4. Future Improvements**
- Full CI/CD with plan → approval → apply.
- CloudWatch alarms (latency, errors, cold starts).
- Model registry for lineage and rollback.
- Multi-account: dev/stage/prod with separate OIDC roles.

---

## **5. How to Present (Interview)**

### **Quick (30s):**
> “A fully serverless image-classification pipeline: CloudFront + S3 frontend → API Gateway → Lambda → SageMaker Serverless (MobileNet V2), all deployed via Terraform. Solved real issues: caching, IAM, endpoint state, and built a reproducible rollout workflow.”

### **Deep-dive (2–3 min):**
- Architecture path + reasoning  
- Terraform orchestration + endpoint lifecycle  
- IAM scoping, caching, error handling  
- Model pipeline (Mobilenet + preprocessing)  
- Improvements: CI/CD, alarms, registry, accounts