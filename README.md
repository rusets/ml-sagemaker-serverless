# ML SageMaker Serverless — Mobilenet V2 Demo

This project demonstrates a **fully automated AWS ML inference pipeline** using Terraform and GitHub Actions.  
It deploys a PyTorch-based MobileNetV2 image classifier on **AWS SageMaker Serverless**, fronted by an **API Gateway + Lambda proxy**, and served through a static **CloudFront + S3 website**.

---

## 🏗️ Architecture (High-Level)

```mermaid
graph TD
  A[User uploads image<br>via browser] --> B[S3 static website<br>(ml-demo.store)]
  B --> C[API Gateway<br>HTTP POST /predict]
  C --> D[Lambda Proxy<br>(Python 3.12)]
  D --> E[SageMaker Serverless<br>Endpoint (MobileNetV2)]
  E --> D
  D --> C
  C --> B
  B --> A
  subgraph AWS Infrastructure
  B
  C
  D
  E
  end
```

---

## 📁 Project Structure

```plaintext
.
├── frontend
│   ├── index.html
│   ├── script.js
│   ├── style.css
│   └── thomas.png
├── infra
│   ├── api_and_config.tf
│   ├── existing.tf
│   ├── iam_lambda_invoke.tf
│   ├── minimal.auto.tfvars
│   ├── model.tar.gz
│   ├── outputs.tf
│   ├── providers.tf
│   ├── sagemaker_deploy.tf
│   └── variables.tf
├── mobilenet_sls
│   └── code
│       ├── inference.py
│       └── requirements.txt
├── scripts
│   └── inference_proxy.py
└── README.md
```

---

## ⚙️ Core Components

- **Frontend** — simple static website hosted on S3 + CloudFront (`https://ml-demo.store/`).
- **Lambda Proxy** — lightweight Python function to relay API calls to SageMaker.
- **SageMaker Endpoint** — serverless inference model (`mobilenet-v2-sls`).
- **API Gateway** — HTTP API v2 used for `/predict` route.
- **Terraform IaC** — manages entire stack reproducibly.
- **GitHub Actions (CI/CD)** — deploys and updates automatically.

---

## 🔒 Security & IAM

This project follows AWS security best practices:

- **KMS (Key Management Service):**
  - The Lambda update process (`lambda_kms_clear`) safely clears and reapplies encryption keys during redeploys.
  - Environment variables are reset in controlled sequence to avoid stale or mismatched KMS bindings.

- **IAM Roles:**
  - **SageMaker Execution Role** (`*-sagemaker-exec`) — minimal permissions to pull containers from ECR and read model artifacts from S3.
  - **Lambda Execution Role** (`*-lambda-exec`) — includes only one inline policy: `sagemaker:InvokeEndpoint` for a specific SageMaker endpoint ARN.
  - **GitHub OIDC Role** — short-lived access for CI/CD without long-term AWS credentials.

This strict IAM separation and dynamic KMS handling ensures secure, auditable deployments.

---

## 💰 Cost Optimization

- **SageMaker Serverless** — billed per inference request (no cost when idle).
- **Lambda + API Gateway** — minimal usage-based pricing, automatically scaled to zero.
- **S3 + CloudFront** — Free Tier friendly; assets cached globally.
- **Model artifact (~14 MB)** — stored once in S3; versioned by timestamp.
- **Automatic sleep/wake pattern** — SageMaker endpoints incur no hourly cost between invocations.

Average monthly cost (for a small demo): **under $1.50/month**.

---

## 🌐 Live Demo

**Website:** [ml-demo.store](https://ml-demo.store/)  
**API Endpoint:** [https://222izyufsl.execute-api.us-east-1.amazonaws.com/predict](https://222izyufsl.execute-api.us-east-1.amazonaws.com/predict)  
**GitHub Repo:** [github.com/rusets/ml-sagemaker-serverless](https://github.com/rusets/ml-sagemaker-serverless)

---

## 🧩 Tech Stack

**AWS:** SageMaker, Lambda, API Gateway, CloudFront, S3, IAM, KMS  
**Infra:** Terraform (v1.6+), AWS Provider (v5.50+)  
**Model:** MobileNetV2 (PyTorch, ImageNet pre-trained)  
**Frontend:** HTML / CSS / JS — lightweight and responsive

---

## 📜 License

MIT © 2025 Ruslan Dashkin
