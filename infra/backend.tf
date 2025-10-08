terraform {
  backend "s3" {
    bucket         = "tfstate-ml-sagemaker-serverless"
    # Name of the dedicated S3 bucket used for storing Terraform state.
    # Keeps state versioned, encrypted, and accessible across environments.

    key            = "terraform/state.tfstate"
    # Path (key) within the bucket where Terraform will store the state file.
    # You can change this path if you want multiple projects or environments.

    region         = "us-east-1"
    # AWS region where both the S3 bucket and DynamoDB table exist.

    encrypt        = true
    # Ensures server-side encryption (SSE-S3) for the Terraform state file.

    dynamodb_table = "ml-sagemaker-serverless"
    # DynamoDB table used for state locking to prevent concurrent apply/destroy operations.
  }
}
