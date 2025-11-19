############################################
# Terraform Backend — S3 + DynamoDB Lock
# Remote, encrypted, collision-safe state storage
############################################
terraform {
  backend "s3" {
    bucket         = "tfstate-ml-sagemaker-serverless"
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ml-sagemaker-serverless"
  }
}
