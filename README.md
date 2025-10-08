# ML SageMaker Serverless + HTTP (S3 backend preconfigured)

Remote backend: S3 `ml-sagemaker-serverless`, DynamoDB `ml-sagemaker-serverless` (you already created them).
Serverless endpoint (zero idle cost) + API Gateway HTTP /predict. CI updates on model.tar.gz.

## Init
```bash
cd infra
terraform init
```

## Apply (no endpoint yet)
```bash
terraform apply   -var 'github_org=<YOUR_GH_ORG>'   -var 'github_repo=<YOUR_REPO>'   -var 'enable_create_endpoint=false'
```

## Build Lambda package
```bash
cd ../scripts
zip -j ../infra/lambda_payload.zip inference_proxy.py
```

## Create endpoint (when model + container image ready)
```bash
cd ../infra
terraform apply   -var 'enable_create_endpoint=true'   -var 'container_image=<ECR CPU DLC URI>'
```

## Test
```bash
API=$(terraform -chdir=infra output -raw apigw_invoke_url)
curl -s -X POST "$API/predict" -H "Content-Type: application/json" -d '{"inputs":"Hello"}' | jq
```
