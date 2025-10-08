# SageMaker Serverless Demo (Mobilenet V2)

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)
![Serverless](https://img.shields.io/badge/Architecture-Serverless-FF4F00?logo=awslambda&logoColor=white)

---

### 🌐 Live Demo
- **Website:** [https://ml-demo.store/](https://ml-demo.store/)
- **API Endpoint:** [`/predict`](https://222izyufsl.execute-api.us-east-1.amazonaws.com/predict)

---

## 📋 Overview

A production‑style, serverless **image classification** project on AWS.  
It deploys **Mobilenet V2** on **Amazon SageMaker Serverless Inference**, exposes it through **API Gateway + Lambda**, and serves a lightweight web UI via **S3 + CloudFront**.  
Infrastructure is defined in **Terraform**, giving reproducible deployments, clear diff history, and easy teardown.

**What this showcases**
- Minimal latency serverless inference without managing servers.
- Clean separation of concerns: static UI, API proxy, ML runtime.
- Solid operational posture: least‑privilege IAM, encrypted state, explicit wiring between services.

---

## 🏗️ Architecture (High‑Level)

> Compact, GitHub‑safe Mermaid diagram with Terraform as the IaC orchestrator.

```mermaid
flowchart LR
  U["User / Browser"] --> CF["Amazon CloudFront"]
  CF --> S3["Amazon S3<br/>Static site + config.js"]
  CF --> APIGW["Amazon API Gateway<br/>HTTP API /predict"]
  APIGW --> LBD["AWS Lambda<br/>Proxy Python 3.12"]
  LBD --> SM["Amazon SageMaker<br/>Serverless Endpoint<br/>Mobilenet V2"]
  SM -->|"Top-5 JSON"| U

  subgraph IaC_Terraform [IaC / Terraform]
    TF["Terraform"]
  end
  TF -.-> CF
  TF -.-> S3
  TF -.-> APIGW
  TF -.-> LBD
  TF -.-> SM
```

**End‑to‑end flow**
1. User opens the site (CloudFront → S3) and selects an image.  
2. Browser sends a JSON payload (base64 image) to **`POST /predict`** on API Gateway.  
3. **Lambda** validates/forwards the payload to **SageMaker Runtime**.  
4. **SageMaker Serverless** returns Top‑5 predictions; Lambda relays JSON back to the browser.  
5. **Terraform** provisions and wires all of the above (buckets, distribution, API, Lambda, roles, endpoint).

---

## ⚙️ Components (Detailed)

**Frontend (S3 + CloudFront)**  
- Static assets only; **`config.js`** holds the live API URL and is re‑uploaded during infra changes (with CloudFront invalidation).  
- CORS enabled on API side; no secrets on the client.

**API Layer (API Gateway HTTP API)**  
- Lightweight edge endpoint for POST `/predict`.  
- Simpler and cheaper than REST API for this use case.

**Lambda Proxy (Python 3.12)**  
- Thin adapter between API Gateway and SageMaker Runtime `InvokeEndpoint`.  
- Handles base64 body, JSON marshalling, CORS response headers.  
- Typical runtime settings here: **timeout ~30s**, **memory 512 MB** (tuned for low latency).

**SageMaker Serverless Endpoint**  
- **Mobilenet V2** (ImageNet) using CPU, pre‑ and post‑processing with `torchvision`.  
- Sample sizing: **2048 MB Memory**, **Max Concurrency 1** (adjust per traffic).  
- Pay‑per‑ms execution; no idle compute cost.

**Terraform IaC**  
- Single source of truth for the entire stack (buckets, distributions, API, Lambda, roles, endpoint).  
- Uses data sources for existing resources and wires integrations and permissions explicitly.

---

## 📁 Project Structure

```plaintext
.
├── frontend/
│   ├── index.html
│   ├── script.js
│   ├── style.css
│   └── thomas.png
├── infra/
│   ├── api_and_config.tf
│   ├── backend.tf
│   ├── existing.tf
│   ├── iam_lambda_invoke.tf
│   ├── minimal.auto.tfvars
│   ├── model.tar.gz
│   ├── outputs.tf
│   ├── providers.tf
│   ├── sagemaker_deploy.tf
│   └── variables.tf
├── mobilenet_sls/
│   └── code/
│       ├── inference.py
│       └── requirements.txt
├── scripts/
│   └── inference_proxy.py
└── README.md
```

> **Terraform state:** stored remotely in **Amazon S3** (AES‑256 server‑side encryption) with **DynamoDB** table for **state locking** — this prevents concurrent applies and guarantees consistency. The backend configuration lives in **`infra/backend.tf`**. (Кратко, без кода.)

---

## 🔒 Security & IAM (Expanded)

**Encryption & secrets**  
- S3 buckets use server‑side encryption.  
- Terraform state is encrypted (SSE‑S3) and versioned; operations use DynamoDB locks.  
- Lambda environment variables are refreshed safely during updates to avoid stale KMS bindings.

**IAM (least privilege)**  
- **SageMaker execution role**: read **model artifacts** from S3 and **pull images** from ECR (read‑only).  
- **Lambda execution role**: **only** `sagemaker:InvokeEndpoint` for the target endpoint ARN.  
- **API Gateway → Lambda permission**: scoped to the specific API ID and route (`POST /predict`).  
- Separation of duties across roles reduces blast radius and improves auditability.

**Network & access**  
- Public static UI; API Gateway controls public API entry.  
- No VPC required for this demo; add VPC endpoints/security groups for private environments.

---

## 💰 Cost Optimization (Detailed)

- **SageMaker Serverless**: pay per request time (ms). Start small (e.g., **2048 MB**, **Max Concurrency 1**) and scale per traffic.  
- **Lambda**: tune memory/timeout to balance cold‑start and cost; keep the proxy thin.  
- **API Gateway (HTTP API)**: cheaper than REST API for similar traffic; use it for simple JSON calls.  
- **CloudFront + S3**: long TTLs for static assets; invalidate only `config.js` and `index.html` on deploy.  
- **Storage**: keep model artifact compact and versioned (tens of MB); clean unused artifacts.  
- **Observability**: short CloudWatch log retention for dev; add filters/alarms only as needed.

Typical demo‑level spend: **~$1–1.5/month** with light traffic (varies by region/usage).

---

## 🚀 Deploy / Destroy (manual)

```bash
cd infra
terraform apply -auto-approve
# ...
terraform destroy -auto-approve
```
> If you orchestrate SageMaker through CLI in `null_resource`, ensure your destroy path also removes endpoint/config/models; or switch to native Terraform SageMaker resources for full lifecycle control.

---

## 🧰 Tech

AWS: SageMaker, Lambda, API Gateway (HTTP), CloudFront, S3, IAM, KMS  
Infra: Terraform ≥ 1.6 (AWS provider ≥ 5.50)  
Model: Mobilenet V2 (PyTorch, ImageNet)  
Frontend: HTML / CSS / JS

---

## 📜 License

MIT © Ruslan
