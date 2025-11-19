############################################
# Input Variables — Regions, Buckets, Names, Parameters
# Defines external inputs for SageMaker, Lambda, API Gateway and CloudFront
############################################

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where all resources are deployed"
}

variable "project_name" {
  type        = string
  default     = "ml-cicd-demo"
  description = "Prefix for naming AWS resources"
}

variable "artifacts_bucket" {
  type        = string
  default     = "ml-cicd-demo-us-east-1-artifacts"
  description = "Existing S3 bucket for model artifacts"
}

variable "site_bucket" {
  type        = string
  default     = "ruslan-aws-rocket-demo"
  description = "Existing S3 bucket for static web content"
}

variable "lambda_function_name" {
  type        = string
  default     = "ml-cicd-demo-proxy"
  description = "Name of the Lambda function used for inference"
}

variable "endpoint_name" {
  type        = string
  default     = "mobilenet-v2-sls"
  description = "Name of the SageMaker serverless endpoint"
}

variable "api_id" {
  type        = string
  description = "Existing API Gateway ID to connect Lambda"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "Existing CloudFront distribution ID for the frontend"
}

variable "domain_name" {
  type        = string
  default     = "ml-demo.store"
  description = "Root domain name used in Route53 and CloudFront"
}

variable "model_key" {
  type        = string
  default     = "models/model.tar.gz"
  description = "Path to the model artifact within S3"
}

variable "serverless_memory_mb" {
  type        = number
  default     = 2048
  description = "Memory size (MB) for the SageMaker serverless endpoint"

  validation {
    condition     = contains([1024, 2048, 3072, 4096, 5120, 6144], var.serverless_memory_mb)
    error_message = "Memory must be one of 1024, 2048, 3072, 4096, 5120, or 6144 MB."
  }
}

variable "serverless_max_conc" {
  type        = number
  default     = 1
  description = "Maximum concurrency for the serverless endpoint"

  validation {
    condition     = var.serverless_max_conc >= 1 && var.serverless_max_conc <= 10
    error_message = "Concurrency must be between 1 and 10."
  }
}

variable "model_version" {
  type        = string
  default     = "v1"
  description = "Version label for the model to trigger redeploys"
}
