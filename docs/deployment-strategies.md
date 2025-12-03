## **Deployment Strategies — Overview**
- Goal: safe model rollouts, minimal downtime, fast rollback.
- Stack: Terraform, SageMaker Serverless, Lambda, API Gateway, CloudFront + S3.

---

## **Current Deployment (This Project)**
- `terraform apply` updates:
  - SageMaker Model + EndpointConfig + Endpoint
  - Lambda variables + API integration
  - `config.js` + CloudFront invalidation
- Endpoint is updated **in-place** using timestamped models.

---

## **In-Place Update (Current)**
- **Pros:** simple, minimal resources.
- **Cons:** brief risk window; rollback = apply previous config.

---

## **Blue/Green (Future Enhancement)**
- Two endpoints (`blue`/`green`), switch after validation.
- **Pros:** safe testing, instant rollback.
- **Cons:** double cost during deployment.

---

## **Canary (Optional)**
- Gradual traffic shift with routing logic + metrics.
- More complex; unnecessary for demo traffic.

---

## **Frontend Deployment**
- Static S3 files, optional versioning.
- Terraform regenerates `config.js`.
- CloudFront invalidates `/config.js` and `/index.html`.
- Zero downtime: cached UI works until refreshed.

---

## **CI/CD (Future)**
- IaC CI: `fmt`, `validate`, `tflint`, `tfsec`, `checkov`, `plan`.
- `apply` on main (manual approval).
- Optional `deploy.yml` / `destroy.yml`.

---

## **Rollback**
- Terraform: reapply previous model/config.
- AWS CLI: switch endpoint to previous config.
- UI: only ensure correct API in `config.js`.

---

## **Safety Checklist**
- Review plan
- Endpoint = `InService`
- `/predict` smoke test OK
- CloudFront invalidation done
- IAM unchanged unexpectedly
- CI security checks passing