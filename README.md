# SageMaker Serverless Demo (Mobilenet V2)

A minimal end‑to‑end demo that serves image classification via an **Amazon SageMaker Serverless Endpoint**, fronted by **API Gateway + Lambda** and a **static web UI on S3 + CloudFront**.

<p align="center">
  <img src="./docs/sagemaker-serverless-architecture.png" alt="Architecture diagram" width="900"/>
</p>

---

## Live endpoints (from the latest `terraform apply`)

- **Demo site:** `https://ml-demo.store`  
- **API URL:** `https://222izyufsl.execute-api.us-east-1.amazonaws.com/predict`  
- **Endpoint name:** `mobilenet-v2-sls`  

These values are auto-wired into `config.js` during deploy.

---

## Architecture (high level)

- **S3 + CloudFront** host the static UI (`index.html`, `script.js`, `style.css`). A small `config.js` file contains `window.DEMO_API_URL` and is uploaded with **no-cache** headers; CloudFront is invalidated so clients always fetch the latest endpoint config.
- **API Gateway (HTTP)** exposes `POST /predict`.
- **Lambda (inference proxy)** receives browser requests and forwards payloads to **SageMaker**.
- **SageMaker Serverless Endpoint** loads the **Mobilenet V2** model and returns predictions.
- **Terraform** provisions the stack end‑to‑end and writes `config.js`.

---

## Repository structure

```
ml-sagemaker-serverless/
├── frontend/                 # Static site
│   ├── index.html
│   ├── script.js
│   └── style.css
├── infra/                    # Terraform (API Gateway, Lambda, S3, CF, SageMaker, IAM)
│   ├── providers.tf
│   ├── variables.tf
│   ├── sagemaker_deploy.tf
│   ├── api_and_config.tf
│   ├── iam_lambda_invoke.tf
│   ├── outputs.tf
│   └── minimal.auto.tfvars
├── mobilenet_sls/
│   └── code/
│       ├── inference.py
│       └── requirements.txt
├── scripts/
│   └── inference_proxy.py
└── docs/
    ├── sagemaker-serverless-architecture.png
    └── sagemaker-serverless-annotated.png
```

---

## Quick start

```
cd infra
terraform init
terraform apply -auto-approve
```

The comments for the commands above are placed here intentionally below the code block, per your style preference.

---

## API (contract)

**Route:** `POST /predict` via API Gateway  
**Body (example):** JSON with either an `image_url` or small inline payload (`base64` if enabled in your proxy).

```
curl -sS -X POST   -H "Content-Type: application/json"   -d '{"image_url":"https://example.com/cat.jpg"}'   https://222izyufsl.execute-api.us-east-1.amazonaws.com/predict
```

The comment for the command above is placed here intentionally below the block.

**Response:** JSON scores/classes produced by the model (Mobilenet V2 in this demo).

---

## Cost profile

- **SageMaker Serverless** — pay per request, no dedicated instances while idle.  
- **Lambda + API Gateway** — request‑driven.  
- **S3 + CloudFront** — minimal for a small static site; CloudFront helps reduce S3 GET costs at scale.  

Tip: keep large test images outside the repo; prefer presigned URLs.

---

## Troubleshooting

- **CORS**: ensure the Lambda proxy sets appropriate headers on the response.  
- **Stale config**: `api_and_config.tf` writes `config.js` and issues a CloudFront invalidation; if the UI doesn’t call the right API, re‑apply or purge cache.  
- **Model not loading**: verify `model.tar.gz` path and IAM permissions in `sagemaker_deploy.tf`.  
- **403 from API**: check Lambda permission resource policy allowing API Gateway to invoke.

---

## Cleanup

```
cd infra
terraform destroy -auto-approve
```

The comment for the command above is placed here intentionally below the block.

---

## 📘 Docs

- **Annotated (AWS services & roles):** `./docs/sagemaker-serverless-annotated.png`
- **Primary diagram (README embed):** `./docs/sagemaker-serverless-architecture.png`
