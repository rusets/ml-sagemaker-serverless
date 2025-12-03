# ADR-005 — Choosing MobileNet V2 Instead of a Custom Model

## Status
Accepted

## Context
The project requires a lightweight image classifier suited for serverless inference with fast cold starts, low memory use, predictable performance, and zero training effort.  
Two options were evaluated:

1. Pretrained ImageNet model (MobileNet V2) ← selected  
2. Custom trained model  

## Option A — Custom Trained Model

**Pros**
- Domain-specific accuracy.  
- Full control over architecture.  

**Cons**
- Requires dataset prep, training, tuning.  
- Larger models → slower cold starts and higher cost.  
- More preprocessing code and complexity.  
- Not needed for an architecture-focused demo.

**Why not chosen**  
Adds overhead and noise without improving what this project aims to demonstrate (IaC, CI/CD, API flow, serverless inference).

## Option B — MobileNet V2 (Selected)

**Pros**
- Small model (~14 MB) with very fast cold starts.  
- Good general accuracy on ImageNet.  
- No training required; simple preprocessing.  
- Easy to load via `torchvision.models`.  
- Ideal for demos and serverless workloads.  
- Works cleanly with AWS DLC containers.

**Cons**
- Not specialized for niche domains.  
- Lower accuracy than heavy models.

**Why chosen**  
Best balance of speed, size, simplicity, and cost efficiency for serverless inference.

## Decision
Use **MobileNet V2 (pretrained ImageNet)** as the inference model — minimal ops overhead, fast startup, predictable behavior, and no training pipeline required.

## Consequences

### Positive
- Sub-second cold starts.  
- Very simple inference logic.  
- Lowest operational cost.  
- Great fit for interview discussions.  

### Negative
- Not ideal for specialized domains.  
- Less impressive for ML-research roles (not the target).

## Summary
MobileNet V2 is ideal for this serverless ML demo: fast, lightweight, cheap, easy to understand, and avoids the complexity of custom training.  
It keeps the focus on AWS architecture, Terraform, CI/CD, and serverless inference.