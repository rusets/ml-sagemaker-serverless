# ADR-002 — Choosing API Gateway HTTP API (v2) Instead of REST API or ALB Lambda Integration

## Status
Accepted

## Context
The project needs a simple public HTTPS endpoint that accepts JSON (base64 image), forwards it to a Lambda proxy, and invokes a SageMaker Serverless endpoint.  
Key requirements: low cost, low latency, minimal config, simple CORS, and easy Terraform automation.

Three options were evaluated:
1. API Gateway REST API  
2. Application Load Balancer (ALB → Lambda)  
3. API Gateway HTTP API v2 ← selected

## Option A — API Gateway REST API
**Pros**
- Many features (usage plans, authorizers, validators).  
- Mature integrations.

**Cons**
- ~3–4× more expensive.  
- Higher latency.  
- More complex routing and config.

**Reason rejected:** Overkill for a single POST `/predict` endpoint.

## Option B — ALB → Lambda
**Pros**
- Cheaper than REST API in some cases.  
- Native Lambda target support.

**Cons**
- ALB hourly cost even at zero traffic.  
- More infrastructure components.  
- Unnecessary for a single Lambda-only workflow.

**Reason rejected:** Not aligned with “zero idle cost” requirement.

## Option C — HTTP API (v2) — Selected
**Pros**
- Lowest cost (pay-per-request).  
- Very simple configuration.  
- Low latency.  
- Built-in CORS.  
- Perfect for JSON-only APIs.  
- Clean Lambda proxy integration.

**Cons**
- Fewer advanced features than REST API.

## Decision
Use **API Gateway HTTP API v2** as the public inference endpoint.  
It provides the best mix of simplicity, cost efficiency, and performance.

## Consequences

### Positive
- Minimal cost and no idle fees.  
- Simple Terraform integration.  
- Clean routing and faster deployments.  
- Ideal for demo-level and interview-level workloads.

### Negative
- Lacks advanced REST API features (not needed here).  
- Future complex requirements may require migrating to REST API.

## Summary
HTTP API v2 is the leanest and fastest solution for a serverless ML demo:  
**cheap, simple, low latency, perfect for `POST /predict`.**