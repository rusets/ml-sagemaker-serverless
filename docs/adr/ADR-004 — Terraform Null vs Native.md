# ADR-004 — Using Terraform null_resource + AWS CLI for SageMaker Instead of Native Terraform SageMaker Resources

## Status
Accepted

## Context
The project deploys a SageMaker Serverless Inference endpoint using timestamped models, dynamic configs, and automatic update/recreate behavior.  
Terraform has native SageMaker resources, but they struggle with:

- timestamped model versions  
- serverless endpoint updates  
- recreate-vs-update logic  
- frequent redeployments  

Two options were evaluated:
1. Native HCL SageMaker resources  
2. Terraform `null_resource` + AWS CLI ← selected  

## Option A — Native Terraform SageMaker Resources

**Pros**
- Pure declarative Terraform.  
- State matches endpoint config.

**Cons**
- Unreliable for serverless endpoints.  
- Endpoint updates fail or get stuck.  
- Terraform doesn’t correctly detect when to recreate.  
- Complex dependency graphs with versioned models.  
- Slow, unstable update cycles.

**Why not chosen**  
Native resources still have lifecycle issues and frequent failures with serverless endpoints and timestamped versions.

## Option B — null_resource + AWS CLI (Selected)

**Pros**
- Deterministic lifecycle: create model, create config, update or recreate endpoint.  
- Reliable detection of endpoint state.  
- Guarantees “wait until InService”.  
- Easy timestamp-based versioning.  
- Fine-grained triggers on any change.

**Cons**
- Imperative scripting.  
- Requires AWS CLI in the runner.  
- Slightly more verbose than pure HCL.

**Why chosen**  
Provides predictable updates and eliminates Terraform SageMaker edge-case failures.

## Decision
Use **Terraform null_resource + AWS CLI** to manage SageMaker models, configs, and endpoints for stable, deterministic deployments.

## Consequences

### Positive
- Full control over update logic.  
- No flakiness during apply/destroy.  
- Easy rollbacks due to versioned models/configs.  
- Clear, observable deployment steps.

### Negative
- Imperative approach adds minor complexity.  
- Terraform state won’t reflect internal SageMaker details.

## Summary
Native SageMaker Terraform resources remain unreliable for serverless inference.  
null_resource + AWS CLI provides the only dependable lifecycle: stable updates, proper versioning, safe recreate logic, and guaranteed InService behavior.