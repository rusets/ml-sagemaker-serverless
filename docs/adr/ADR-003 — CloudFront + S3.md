# ADR-003 — Choosing CloudFront + S3 for the Frontend Instead of ALB, Amplify, or API Gateway

## Status
Accepted

## Context
The project needs a public static UI for uploading an image, previewing it, and sending a JSON request to `/predict`.  
Requirements: global performance, HTTPS, CORS-friendly, zero maintenance, pay-per-traffic, cache invalidation for `config.js`, and full Terraform automation.

Four options were evaluated:
1. S3 + CloudFront ← selected  
2. API Gateway static hosting  
3. ALB static hosting  
4. AWS Amplify Hosting  

## Option A — S3 + CloudFront (Selected)

**Pros**
- Fast global delivery via CloudFront.  
- Lowest cost (S3 + CDN).  
- Native static hosting; no servers.  
- Easy cache invalidation for `config.js`.  
- Built-in HTTPS (ACM + CloudFront).  

**Cons**
- Two resources instead of one.  
- Must automate invalidations.  

**Why chosen**  
Best performance, lowest cost, and ideal for static SPAs.

## Option B — API Gateway as a static host
**Pros**
- Can technically return static content.

**Cons**
- Not meant for full sites.  
- No CDN, no caching, expensive for static files.  
- Requires embedding HTML/CSS/JS.

**Why not chosen**  
API Gateway is for APIs, not UIs.

## Option C — ALB (Application Load Balancer)
**Pros**
- Useful when mixing multiple dynamic services.

**Cons**
- Has hourly cost.  
- No native static hosting.  
- Requires certificates, listeners, SGs.

**Why not chosen**  
Not serverless and too complex for a simple static site.

## Option D — AWS Amplify Hosting
**Pros**
- Very easy static hosting with built-in pipeline.

**Cons**
- More expensive for simple sites.  
- Overkill for minimal HTML/JS.  
- Terraform support weaker.

**Why not chosen**  
Great for frameworks, unnecessary here.

## Decision
Use **S3 + CloudFront** for frontend hosting — fast, global, cheap, and fully serverless.  
Works naturally with Terraform and supports targeted cache invalidation.

## Consequences

**Positive**
- Very low cost and global distribution.  
- Strong caching and CDN performance.  
- Simple invalidation of individual files.  
- Ideal for lightweight static frontends.

**Negative**
- Requires managing S3 + CloudFront together.  
- Invalidations must be automated (already done).

## Summary
S3 + CloudFront is the AWS-standard pattern for static sites:  
**cheap, serverless, global, fast, and perfect for this demo.**