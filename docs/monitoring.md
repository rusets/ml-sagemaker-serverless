# **Monitoring — Overview**
Purpose: visibility into latency, availability, and failures across the full inference path.  
Scope: CloudFront, S3, API Gateway, Lambda, SageMaker Serverless, Terraform CI.  
Tools: CloudWatch Metrics, Logs, Dashboards, optional alarms.

---

## **Key Metrics**

### **CloudFront**
- RequestCount  
- 4XX / 5XX ErrorRate  
- CacheHitRate  
- OriginLatency  
- BytesDownloaded / Uploaded  

### **S3 (Static Site + config.js)**
- BucketSizeBytes  
- Get / Put Requests  
- 4xx / 5xx Errors  
- config.js upload errors from CI  

### **API Gateway (HTTP API)**
- Count  
- Latency (integration)  
- 4XX / 5XX  
- Integration Errors  
- Throttles  
- CORS Preflight Errors  

### **Lambda Proxy**
- Invocations  
- Errors / Throttles  
- Duration (P50 / P90 / P99)  
- ColdStarts  
- ConcurrentExecutions  
- Custom log-based signals (malformed payload, missing env vars)  

### **SageMaker Serverless**
- InvocationRequests  
- Invocation4XX / 5XX  
- ModelLatency  
- OverheadLatency  
- ServerlessConcurrencyUtilization  
- EndpointStatus transitions (Creating / Updating / InService / Failed)  

---

## **Log Groups**
- `/aws/lambda/<name>`  
- `/aws/sagemaker/Endpoints/<name>`  
- `/aws/apigateway/<api-id>`  
- CloudFront logs (optional S3 or Firehose)  

---

## **Dashboards — Required Panels**
- **API Gateway:** count, latency, 4XX/5XX  
- **Lambda:** duration, errors, throttles, cold starts  
- **SageMaker:** ModelLatency, invocation count, endpoint state timeline  
- **CloudFront:** cache hit ratio, errors, latency  
- **S3:** errors + config.js operations  
- **Terraform CI:** last pipeline results  

---

## **Alerts — Recommended**
- API Gateway 5XXErrorRate > 1%  
- Lambda Errors > 0.5%  
- Lambda P90 Duration > 2s  
- SageMaker ModelLatency P90 > 1.5s  
- EndpointStatus = Failed  
- CloudFront CacheHitRate < 80%  
- Terraform apply failure  

---

## **Optional Tracing**
- X-Ray for Lambda → SageMaker path  
- Captures: latency, retry behavior, dependency timings  

---

## **Minimum Monitoring Checklist**
- CloudWatch dashboard present  
- Alerts configured (API / Lambda / SageMaker)  
- Log retention set (14–30 days)  
- Terraform pipeline green  
- CloudFront cache hit ratio monitored  