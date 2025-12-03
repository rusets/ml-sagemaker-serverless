## **Architecture — Overview**
```text

ml-sagemaker-serverless/
├── .github/                         # GitHub Actions + templates
│   ├── ISSUE_TEMPLATE/              # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md     # PR template
│   └── workflows/                   # CI/CD
│       ├── deploy.yml               # Deploy infra
│       ├── destroy.yml              # Teardown
│       └── iac-ci.yml               # Terraform CI checks
│
├── docs/                            # Project documentation
│   ├── adr/                         # Architecture decisions
│   ├── diagrams/                    # Architecture diagrams
│   ├── runbooks/                    # Troubleshooting guides
│   ├── screenshots/                 # UI + infra screenshots
│   ├── architecture.md              # System design
│   ├── cost.md                      # Cost model
│   ├── deployment-strategies.md     # Rollout/rollback
│   ├── monitoring.md                # Metrics & alerts
│   ├── slo.md                       # SLO/SLI
│   ├── threat-model.md              # Security risks
│   ├── security.md                  # IAM & protection
│   └── interview.md                 # Interview summary
│
├── frontend/                        # Static UI (S3 + CloudFront)
│   ├── index.html                   # UI page
│   ├── script.js                    # API calls
│   ├── style.css                    # Styles
│   └── thomas.png                   # Demo image
│
├── infra/                           # Terraform IaC
│   ├── api_and_config.tf            # API + config.js
│   ├── backend.tf                   # Remote state
│   ├── existing.tf                  # Data sources
│   ├── iam_lambda_invoke.tf         # IAM policies
│   ├── minimal.auto.tfvars          # External variables
│   ├── outputs.tf                   # Outputs
│   ├── providers.tf                 # AWS provider
│   ├── sagemaker_deploy.tf          # SM deploy logic
│   └── variables.tf                 # Inputs
│
├── mobilenet_sls/                   # SageMaker inference
│   └── code/
│       ├── inference.py             # Model logic
│       └── requirements.txt         # Dependencies
│
├── scripts/
│   └── inference_proxy.py           # Lambda proxy
│
├── .tflint.hcl                      # Terraform lint rules
├── .gitignore                       # Ignore patterns
├── LICENSE                          # MIT license
└── README.md                        # Main documentation

```

## **Architecture — Overview (Short)**

- **Project:** `ml-sagemaker-serverless` — serverless image classification on AWS (MobileNet V2).
- **Pattern:** Browser → CloudFront → S3 → API Gateway (HTTP API) → Lambda → SageMaker Serverless Endpoint.
- **Infra:** Terraform with remote state in S3 + DynamoDB lock, encrypted with SSE.

---

## **Core Components**

- **CloudFront**
  - Global CDN, HTTPS, caching for static UI.
- **S3 (Static Site)**
  - Hosts HTML/CSS/JS and `config.js` with live API URL.
- **API Gateway HTTP API**
  - Public `POST /predict` JSON endpoint.
- **Lambda Proxy (Python)**
  - Reads Base64 image from JSON.
  - Calls SageMaker Runtime `InvokeEndpoint`.
  - Returns Top-5 prediction JSON with CORS headers.
- **SageMaker Serverless Endpoint**
  - MobileNet V2 (ImageNet), CPU-only, pay-per-request.

---

## **Terraform Responsibilities**

- Configure S3 backend + DynamoDB lock, with SSE for state.
- Wire IAM roles and least-privilege policies (Lambda → SageMaker, API → Lambda).
- Use `null_resource` + AWS CLI to:
  - Create timestamped Model and EndpointConfig.
  - Create or update Endpoint and wait for `InService`.
- Generate and upload `config.js`, then invalidate CloudFront paths.

---

## **Non-Functional Properties**

- **Scalability:** All components auto-scale; no servers to manage.
- **Security:** No AWS keys in frontend; IAM scoped to specific resources; encrypted state.
- **Cost:** No idle compute; main cost is invocations + traffic (SageMaker, Lambda, API GW, CloudFront).
- **Interview Value:** Demonstrates full serverless ML pipeline with clear separation of UI, API, proxy, inference, and IaC.