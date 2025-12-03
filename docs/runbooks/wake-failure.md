# Runbook: Wake Failure

## Summary
This runbook covers issues where the Wake Lambda or `/predict` API call fails due to the SageMaker endpoint being unavailable, cold, or stuck in a non-InService state.

## When to Use
- The UI shows errors during prediction.
- The API returns 500, 502, or "Endpoint is not in service".
- Terraform apply hangs or fails on the SageMaker update step.

## Symptoms
- Lambda logs show `ModelError`, `InvocationException`, or timeout.
- API Gateway returns 502 Bad Gateway.
- SageMaker endpoint status is not "InService".
- Terraform reports `Resource is updating`.

## Root Cause
- SageMaker endpoint stuck in Updating/Creating.
- Cold start taking too long for large model or insufficient memory.
- Past update attempt failed and left endpoint in partial state.

## Resolution Steps

### Step 1 — Check Endpoint Status
```bash
aws sagemaker describe-endpoint \
  --endpoint-name "$ENDPOINT_NAME" \
  --region "$AWS_REGION" \
  --output table
```

Expected value:
- `InService`

If not InService → continue to Step 2.

### Step 2 — Check Endpoint Configuration
```bash
aws sagemaker describe-endpoint-config \
  --endpoint-config-name "$CONFIG_NAME" \
  --region "$AWS_REGION" \
  --output table
```

### Step 3 — Restart the Endpoint
```bash
aws sagemaker delete-endpoint \
  --endpoint-name "$ENDPOINT_NAME" \
  --region "$AWS_REGION"

aws sagemaker create-endpoint \
  --endpoint-name "$ENDPOINT_NAME" \
  --endpoint-config-name "$CONFIG_NAME" \
  --region "$AWS_REGION"
```

### Step 4 — Validate Prediction
```bash
curl -X POST "$API_URL/predict" \
  -H "Content-Type: application/json" \
  -d '{"ping": true}'
```

## Post-Fix Checks
- Endpoint status = InService
- Lambda logs show successful invocation
- UI prediction works
- Terraform shows no pending changes

## Prevention
- Increase serverless memory for faster cold starts.
- Add CloudWatch alarm for endpoint update delays.
- Add retry logic in the Wake Lambda.