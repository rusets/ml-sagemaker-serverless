config {
  format = "default"
  call_module_type = "local"
}

plugin "aws" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_s3_bucket_public_access" {
  enabled = true
}

rule "aws_iam_policy_document_invalid_json" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_deprecated_interpolations" {
  enabled = true
}