############################################
# Providers & IAM Roles — Terraform + AWS
# Defines provider versions and required IAM roles for SageMaker
############################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_iam_role" "sagemaker_exec" {
  name = "${var.project_name}-sagemaker-exec"
}
