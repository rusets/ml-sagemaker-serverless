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

Production-style, serverless **image classification** pipeline on AWS: **SageMaker Serverless Inference** (Mobilenet V2) behind **API Gateway + Lambda**, with a static web UI via **S3 + CloudFront**. Infrastructure is fully automated using **Terraform** (state in S3, locks in DynamoDB).

---

## 🏗️ Architecture (High‑Level)

> Compact horizontal diagram (keeps README tidy). Terraform appears as the IaC orchestrator.

```mermaid
flowchart LR
  User([User<br/>Browser]) --> CF[Amazon CloudFront]
  CF --> S3[Amazon S3<br/>Static site + config.js]
  CF --> APIGW[Amazon API Gateway<br/>HTTP API /predict]
  APIGW --> LAMBDA[AWS Lambda<br/>Proxy (Python 3.12)]
  LAMBDA --> SM[Amazon SageMaker<br/>Serverless Endpoint<br/>Mobilenet V2]
  SM -->|Top‑5 JSON| User

  subgraph IaC
    TF[Terraform]
  end
  TF -.-> CF
  TF -.-> S3
  TF -.-> APIGW
  TF -.-> LAMBDA
  TF -.-> SM
```

**Flow:** The user opens the site (CloudFront → S3) and issues a POST `/predict` (API Gateway). Lambda forwards payloads to **SageMaker Serverless**, receives Top‑5 predictions, and responds to the browser. **Terraform** provisions and wires all components.

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

> Terraform stores its infrastructure state remotely in **Amazon S3** (AES‑256 encrypted) and uses **DynamoDB for state locking**, ensuring consistency and safe collaboration during deployments.

---

## 🔒 Security & IAM

- **KMS & Lambda env:** updates reset KMS binding and environment variables in a controlled order to avoid stale encryption state.  
- **Least‑privilege IAM:**  
  - *SageMaker execution role* — read model artifacts from S3 and pull images from ECR (read‑only).  
  - *Lambda execution role* — only `sagemaker:InvokeEndpoint` on the specific endpoint ARN.  
  - *API Gateway → Lambda permission* — scoped to `POST /predict` for this API.

---

## 💰 Cost Optimization

- **SageMaker Serverless** — billed per request time (ms). No idle compute.  
- **Lambda + HTTP API** — usage‑based, scales to zero; minimize timeout/memory for latency/cost balance.  
- **CloudFront + S3** — global caching for static assets, low egress and S3 GETs.  
- **Small artifact (~tens of MB)** — efficient and versioned, reducing update overhead.

Typical monthly cost for light demo traffic: **~$1–1.5/month**.

---

## 🚀 Deploy / Destroy (quick)

```bash
cd infra
terraform apply -auto-approve
# ...
terraform destroy -auto-approve
```
> If you orchestrate SageMaker via CLI in `null_resource`, ensure your destroy path removes endpoint/config/models; or switch to native Terraform SageMaker resources.

---

## 🧰 Tech

AWS: SageMaker, Lambda, API Gateway (HTTP), CloudFront, S3, IAM, KMS  
Infra: Terraform ≥ 1.6 (AWS provider ≥ 5.50)  
Model: Mobilenet V2 (PyTorch, ImageNet)  
Frontend: HTML / CSS / JS

---

## 📜 License

MIT © Ruslan
