# 🧠 SageMaker Serverless Demo (Mobilenet V2)

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)
![Serverless](https://img.shields.io/badge/Architecture-Serverless-FF4F00?logo=awslambda&logoColor=white)
![SageMaker](https://img.shields.io/badge/AI-SageMaker-232F3E?logo=amazonaws&logoColor=white)

---

## 📋 Overview

A minimal end-to-end **serverless image classification** demo using AWS services.  
The project serves a simple web interface via **S3 + CloudFront** that connects through an **API Gateway** and **Lambda proxy** to an **Amazon SageMaker Serverless Endpoint** running **Mobilenet V2** for image recognition.

---

## 🏗️ Architecture (high-level)

```mermaid
flowchart LR
  %% Node styles
  classDef svc fill:#f8f9ff,stroke:#6366f1,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef ext fill:#fff7ed,stroke:#fb923c,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef iac fill:#eef2ff,stroke:#7c3aed,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef data fill:#ecfdf5,stroke:#10b981,stroke-width:1.5,rx:10,ry:10,color:#111827

  %% Frontend
  user((User / Browser)):::ext --> cf["Amazon CloudFront"]:::svc
  cf --> s3["Amazon S3<br/>Static site + config.js"]:::data

  %% API Layer
  cf --> apigw["Amazon API Gateway<br/>HTTP API"]:::svc
  apigw --> lam["AWS Lambda<br/>Inference Proxy"]:::svc
  lam --> sm["Amazon SageMaker<br/>Serverless Endpoint<br/>Mobilenet V2"]:::svc
  sm -->|JSON Response| user

  %% IaC & CI/CD
  subgraph IaC_CICD [Infrastructure as Code / CI-CD]
    gh["GitHub Actions"]:::ext --> tf["Terraform"]:::iac
  end
  tf -.-> s3
  tf -.-> cf
  tf -.-> apigw
  tf -.-> lam
  tf -.-> sm
```

---

## ✨ Features

- **Serverless** architecture — zero idle cost  
- **Terraform** end-to-end provisioning  
- **SageMaker Serverless Endpoint** for ML inference  
- **API Gateway + Lambda** integration layer  
- **S3 + CloudFront** for static web hosting  
- Simple and cost-efficient ML deployment demo  

---

## 🚀 Deployment

**Requirements**
- AWS CLI configured  
- Terraform ≥ 1.5 installed  
- Pre-trained model archive: `infra/model.tar.gz`  

```bash
cd infra
terraform init
terraform apply -auto-approve
```

The comments for the commands above are intentionally placed below the block per your style preference.

---

## 💰 Cost Optimization

| Service | Optimization | Description |
|----------|---------------|-------------|
| **SageMaker** | Serverless Endpoint | Pay only for invocation time |
| **Lambda** | On-demand execution | Auto-scales, no idle time |
| **CloudFront** | CDN caching | Reduces S3 reads & latency |
| **S3** | Static website | Low-cost storage for assets |
| **API Gateway** | HTTP API | Cheaper than REST API |
| **Terraform** | Easy teardown | Run destroy to stop charges |

---

## 📂 Folder Structure

```
ml-sagemaker-serverless/
├── frontend/
│   ├── index.html
│   ├── out.json
│   ├── script.js
│   ├── style.css
│   └── thomas.png
├── infra/
│   ├── api_and_config.tf
│   ├── existing.tf
│   ├── iam_lambda_invoke.tf
│   ├── minimal.auto.tfvars
│   ├── model.tar.gz
│   ├── outputs.tf
│   ├── providers.tf
│   ├── sagemaker_deploy.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
├── mobilenet_sls/
│   └── code/
│       ├── inference.py
│       └── requirements.txt
├── scripts/
│   └── inference_proxy.py
└── terraform.tfstate
```

---

## 🧹 Cleanup

```bash
cd infra
terraform destroy -auto-approve
```

The comment for the command above is intentionally placed below the block.

---

## 🪪 License

MIT — use freely for demos and learning.

---

> This project demonstrates a production-ready **serverless ML inference pipeline** using modern AWS services and Terraform.
