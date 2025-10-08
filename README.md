# 🧠 SageMaker Serverless Demo (Mobilenet V2)

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)
![Serverless](https://img.shields.io/badge/Architecture-Serverless-FF4F00?logo=awslambda&logoColor=white)
![SageMaker](https://img.shields.io/badge/AI-SageMaker-232F3E?logo=amazonaws&logoColor=white)

---

## 📋 Overview

A minimal end-to-end **serverless image classification** app on AWS.  
The web UI (S3 + CloudFront) calls an **HTTP API** (API Gateway) that invokes **AWS Lambda** (proxy) to the **Amazon SageMaker Serverless Endpoint** running **Mobilenet V2**.

---

## 🏗️ Architecture (high-level)

```mermaid
flowchart LR
  %% STYLE
  classDef svc fill:#f8f9ff,stroke:#6366f1,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef ext fill:#fff7ed,stroke:#fb923c,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef iac fill:#eef2ff,stroke:#7c3aed,stroke-width:1.5,rx:10,ry:10,color:#111827
  classDef data fill:#ecfdf5,stroke:#10b981,stroke-width:1.5,rx:10,ry:10,color:#111827

  %% USER / FRONTEND
  user((User\nBrowser)):::ext --> cf[Amazon CloudFront]:::svc
  cf --> s3[(Amazon S3\nStatic site + config.js)]:::data

  %% API LAYER
  cf --> apigw[Amazon API Gateway (HTTP API)]:::svc
  apigw --> lam[AWS Lambda\n(inference proxy)]:::svc
  lam --> sm[Amazon SageMaker\nServerless Endpoint (Mobilenet V2)]:::svc
  sm -->|JSON| user

  %% CI/CD + IaC
  subgraph Provisioning / CI
    gh[(GitHub Actions)]:::ext --> tf[Terraform]:::iac
  end
  tf -.-> s3
  tf -.-> cf
  tf -.-> apigw
  tf -.-> lam
  tf -.-> sm
```

---

## ✨ Features

- 100% **serverless** request-driven inference  
- **Pay-per-inference** (no idle EC2) via SageMaker Serverless  
- **Static UI** with CDN (S3 + CloudFront)  
- **Terraform** deploys all resources end-to-end  
- Cache-busting of `config.js` via CloudFront invalidation

---

## 🚀 Deployment

**Prereqs**
- AWS CLI configured
- Terraform ≥ 1.5
- `infra/model.tar.gz` present or public model location defined in Terraform

```bash
cd infra
terraform init
terraform apply -auto-approve
```

The comments for the commands above are intentionally placed below the block per your style preference.

What happens on apply:
- Creates IAM roles and policies  
- Deploys SageMaker model + serverless endpoint  
- Creates API Gateway (HTTP) + Lambda proxy integration  
- Uploads `config.js` with API URL and invalidates CloudFront  
- Serves the static site via CloudFront domain

---

## 🔌 API (contract)

**Route:** `POST /predict` (API Gateway HTTP)  
**Body (example):** JSON with `image_url` (or base64 if enabled).

```bash
curl -sS -X POST   -H "Content-Type: application/json"   -d '{"image_url":"https://example.com/cat.jpg"}'   https://<api-id>.execute-api.<region>.amazonaws.com/predict
```

The comment for the command above is intentionally placed below the block.

**Response:** JSON with predicted class/scores from Mobilenet V2.

---

## 💰 Cost Optimization

| Service | Approach | Note |
|---|---|---|
| SageMaker | **Serverless Inference** | Pay only per request duration/compute |
| API Gateway | **HTTP API** | Cheaper/faster than REST API for this use |
| Lambda | **Short-lived proxy** | Minimal memory/timeout; warm paths via traffic |
| CloudFront | **CDN caching** | Lowers S3 reads & accelerates global delivery |
| S3 | **Static website** | Store small assets; avoid large binaries in repo |
| Terraform | **Idempotent teardown** | Destroy when idle to stop all charges |

Tip: Keep test images external (presigned URLs) to avoid storage/egress surprises.

---

## 🔮 Future Improvements

- GitHub Actions CI/CD (plan/apply, invalidations, linting)  
- Cognito or IAM auth for `/predict`  
- CloudWatch metrics/alarms dashboard  
- Data pre/post-processing layer (image resize, thresholding)  
- Multi-model endpoints or model registry promotion  
- SVG diagram variant for crisp zoom at any scale

---

## 🧰 Tech Stack

- **AWS:** SageMaker Serverless, Lambda, API Gateway (HTTP), S3, CloudFront, IAM, CloudWatch  
- **Language:** Python 3.10 (inference proxy + model handler)  
- **IaC:** Terraform

---

## 📂 Folder Structure

```
ml-sagemaker-serverless/
├── frontend/                 # Static site (HTML, JS, CSS)
├── infra/                    # Terraform (SageMaker, API GW, Lambda, S3, CF, IAM)
├── mobilenet_sls/            # Model code (inference.py, requirements.txt)
├── scripts/                  # Lambda proxy (inference_proxy.py)
└── docs/                     # (optional) extra images/diagrams
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

MIT — use and adapt for demos and learning.

---

> Designed for demonstration and portfolio purposes.  
> Shows how to deploy a production-ready **serverless ML inference pipeline** using modern AWS services.
