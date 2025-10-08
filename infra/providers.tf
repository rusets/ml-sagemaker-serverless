terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.50" }
  }
}

provider "aws" {
  region = var.region
}

data "aws_iam_role" "sagemaker_exec" {
  name = "${var.project_name}-sagemaker-exec"
}

resource "aws_iam_role_policy_attachment" "sagemaker_exec_ecr_ro" {
  role       = data.aws_iam_role.sagemaker_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}