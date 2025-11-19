############################################
# Data Sources — Existing AWS Resources
# Provides account metadata, Lambda lookup and API Gateway info
############################################

data "aws_caller_identity" "me" {}

data "aws_lambda_function" "proxy" {
  function_name = var.lambda_function_name
}

data "aws_apigatewayv2_api" "api" {
  api_id = var.api_id
}
