## **Cost — Overview**
- Goal: keep the full ML stack around **$1–2/month**.
- Main services: CloudFront, S3, API Gateway, Lambda, SageMaker Serverless, DynamoDB (state lock).

---

## **SageMaker Serverless**
- Pay-per-inference (duration × memory).
- Works cheapest with:
  - **2048 MB** memory
  - **MaxConcurrency = 1**
  - **MobileNet V2** (small model)
- Watch: ModelLatency P50/P90/P99, invocation volume.

---

## **Lambda Proxy**
- Cost = GB-seconds + requests.
- Setup: **512 MB**, <300 ms average.
- Optimizations:
  - Thin proxy logic
  - Fast Python runtime
- Watch: duration spikes, error rate.

---

## **API Gateway (HTTP API)**
- Very cheap, per-request billing.
- Use HTTP API instead of REST API.
- Watch: 4XX/5XX, integration latency.

---

## **CloudFront**
- Main costs: data transfer + requests.
- Reduce cost by:
  - High cache hit ratio
  - Small static assets
  - Targeted invalidations (`index.html`, `config.js`)
- Watch: CacheHitRate, 5XX, bytes transferred.

---

## **S3 (Frontend + State)**
- Low cost: storage + small request volume.
- Keep only static UI + small model artifacts.
- Watch: bucket size, number of requests.

---

## **Terraform State (S3 + DynamoDB)**
- S3: cents per month.
- DynamoDB lock table: ~**$0.50/month**.
- Use cheapest RCU/WCU settings.

---

## **Estimated Monthly Cost**
- SageMaker: **$0.60–$1.10**
- API Gateway: **$0.05–$0.10**
- Lambda: **~$0.05**
- CloudFront: **$0.10–$0.30**
- S3: **~$0.10**
- DynamoDB: **~$0.50**

**Total: ~ $1.40–$2.00 / month**

---

## **Cost Optimization Checklist**
- MaxConcurrency = **1**
- Use **MobileNet V2** (small footprint)
- Use **HTTP API**
- High CloudFront cache hit rate
- Keep S3 assets minimal
- Low DynamoDB capacity