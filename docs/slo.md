## **Service Level Objectives (SLOs)**

## **Scope**
- API: `/predict` (HTTP API Gateway)
- Components: CloudFront, S3, API Gateway, Lambda Proxy, SageMaker Serverless Endpoint
- Users: Browser-based clients submitting image classification requests

## **SLO — Availability**
- Target availability: **99.5%**
- Measurement source:
  - API Gateway 5XX errors
  - Lambda invocation failures
  - SageMaker endpoint `ServiceUnavailable`
- Error budget:
  - Allowed unavailability: **0.5% per 30 days**
- Budget burn alerts:
  - Warning at 50% budget burn
  - Critical at 90% budget burn

## **SLO — Latency**
- Target P90 end-to-end latency: **< 900 ms**
- Components included:
  - Client → API Gateway
  - API Gateway → Lambda
  - Lambda → SageMaker InvokeEndpoint
  - SageMaker inference duration
- Cold start impact:
  - Acceptable: 1–2 slow requests after idle periods
  - Not counted toward P90 if duration < 120 seconds window

## **SLI — Latency Measurements**
- Measured from:
  - Lambda duration metric
  - API Gateway integration latency metric
  - SageMaker `ModelLatency` metric
- Aggregation:
  - Compute P50 / P90 / P99 daily
  - Store metrics in dashboard

## **SLO — Correctness**
- Definition: Response is valid JSON containing Top-5 predictions
- Error conditions:
  - Lambda returns error or malformed body
  - SageMaker returns non-JSON output
  - Missing labels or probabilities
- Allowed incorrect responses:
  - **< 0.1% of all requests**

## **SLO — Freshness (Config.js)**
- Config propagation must complete in **< 60 seconds**
- Conditions covered:
  - Terraform updates API endpoint
  - `config_autogen` uploads new file to S3
  - CloudFront invalidation applied
- Monitoring:
  - CloudFront invalidation metrics
  - S3 object version change

## **SLO — Security**
- IAM privilege boundaries must remain valid
- Required conditions:
  - Lambda can invoke only **one** endpoint ARN
  - SageMaker execution role has **read-only** ECR
  - No public S3 ACLs
- Violations:
  - Any IAM drift → automatic failure in CI

## **SLO — Terraform Reliability**
- Successful Terraform apply: **100%**
- Requirements:
  - No concurrent apply (DynamoDB lock)
  - No stale Lambda env vars
  - Endpoint transitions complete within **10 minutes**
- Failure alert:
  - If apply fails twice consecutively

## **Alerting — Minimum Requirements**
- API Gateway 5XX > 1% for 5 minutes
- Lambda errors > 0.5% for 5 minutes
- P90 latency > SLO for 10 consecutive minutes
- SageMaker endpoint not `InService` for > 5 minutes
- Terraform action fails in CI

## **Dashboard Requirements**
- API Gateway: request count, 4XX, 5XX, integration latency
- Lambda: duration, errors, throttles, cold starts
- SageMaker: ModelLatency, InvocationRequests, InvocationErrors
- CloudFront: cache hit ratio, 4XX and 5XX
- Terraform CI: apply/destroy success tracking