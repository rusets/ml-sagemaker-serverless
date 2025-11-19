############################################
# Lambda Permission — API Gateway → Lambda
# Grants API Gateway ability to invoke POST /predict
############################################
resource "aws_lambda_permission" "allow_apigw_post_predict" {
  statement_id  = "allow-apigw-post-${var.project_name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.me.account_id}:${var.api_id}/*/POST/predict"
}


############################################
# Lambda Runtime Tune — Timeout & Memory
# Post-provision update for runtime settings
############################################
resource "null_resource" "lambda_runtime_tune" {
  triggers = {
    function_name = var.lambda_function_name
    timeout_sec   = "30"
    memory_mb     = "512"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      FN   = var.lambda_function_name
      TOUT = "30"
      MEM  = "512"
    }
    command = <<-EOT
      set -euo pipefail
      aws lambda update-function-configuration --function-name "$FN" --timeout "$TOUT" --memory-size "$MEM"
      aws lambda wait function-updated --function-name "$FN"
    EOT
  }
}


############################################
# Lambda KMS & Env Clear — Reset Runtime State
# Ensures clean environment & no stale KMS bindings
############################################
resource "null_resource" "lambda_kms_clear" {
  depends_on = [null_resource.lambda_runtime_tune]

  triggers = {
    function_name = var.lambda_function_name
    endpoint_name = var.endpoint_name
    region        = var.region
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      FN  = var.lambda_function_name
      EP  = var.endpoint_name
      REG = var.region
    }
    command = <<-EOT
      set -euo pipefail

      for i in {1..18}; do
        st=$(aws lambda get-function-configuration --function-name "$FN" --query 'LastUpdateStatus' --output text 2>/dev/null || echo Unknown)
        [ "$st" = "InProgress" ] && sleep 5 || break
      done

      aws lambda update-function-configuration --function-name "$FN" --kms-key-arn ""
      aws lambda wait function-updated --function-name "$FN"

      aws lambda update-function-configuration --function-name "$FN" --environment "Variables={}"
      aws lambda wait function-updated --function-name "$FN"

      TS=$(date +%s)
      aws lambda update-function-configuration --function-name "$FN" --environment "Variables={ENDPOINT_NAME=$EP,REGION=$REG,APP_TOUCH=$TS}"
      aws lambda wait function-updated --function-name "$FN"
    EOT
  }
}


############################################
# Lambda Env Refresh — Finalize Variables
# Sets ENDPOINT_NAME/REGION and publishes new version
############################################
resource "null_resource" "lambda_env_refresh" {
  depends_on = [null_resource.lambda_kms_clear]

  triggers = {
    function_name = var.lambda_function_name
    endpoint_name = var.endpoint_name
    region        = var.region
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      FN  = var.lambda_function_name
      EP  = var.endpoint_name
      REG = var.region
    }
    command = <<-EOT
      set -euo pipefail
      aws lambda update-function-configuration --function-name "$FN" --environment "Variables={ENDPOINT_NAME=$EP,REGION=$REG}"
      aws lambda wait function-updated --function-name "$FN"
      aws lambda publish-version --function-name "$FN" --description "env refresh"
    EOT
  }
}


############################################
# API Gateway Integration — Point to Latest Lambda
# Updates IntegrationUri to unqualified Lambda ARN
############################################
resource "null_resource" "apigw_integration_unqualified" {
  depends_on = [null_resource.lambda_env_refresh]

  triggers = {
    api_id        = var.api_id
    function_name = var.lambda_function_name
    pfv           = "2.0"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      API = var.api_id
      FN  = var.lambda_function_name
    }
    command = <<-EOT
      set -euo pipefail
      FN_ARN=$(aws lambda get-function --function-name "$FN" --query 'Configuration.FunctionArn' --output text)
      INT_ID=$(aws apigatewayv2 get-integrations --api-id "$API" --query "Items[?contains(IntegrationUri, 'function:$FN')].[IntegrationId]" --output text | head -n1)
      aws apigatewayv2 update-integration --api-id "$API" --integration-id "$INT_ID" --integration-uri "$FN_ARN" --payload-format-version "2.0"
    EOT
  }
}


############################################
# Frontend Config Autogen — S3 Upload & CF Invalidation
# Generates config.js with API URL and pushes to static site
############################################
resource "null_resource" "config_autogen" {
  depends_on = [
    aws_lambda_permission.allow_apigw_post_predict,
    null_resource.lambda_runtime_tune,
    null_resource.lambda_kms_clear,
    null_resource.lambda_env_refresh,
    null_resource.apigw_integration_unqualified,
    null_resource.sm_update
  ]

  triggers = {
    api_endpoint = data.aws_apigatewayv2_api.api.api_endpoint
    site_bucket  = var.site_bucket
    cf_id        = var.cloudfront_distribution_id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      API_ENDPOINT = data.aws_apigatewayv2_api.api.api_endpoint
      SITE_BUCKET  = var.site_bucket
      CF_ID        = var.cloudfront_distribution_id
    }
    command = <<-EOT
      set -euo pipefail
      API_URL="$API_ENDPOINT/predict"
      printf 'window.DEMO_API_URL = "%s";\n' "$API_URL" > /tmp/config.js

      aws s3 cp /tmp/config.js "s3://$SITE_BUCKET/config.js" \
        --content-type application/javascript \
        --cache-control "no-cache, must-revalidate" >/dev/null

      aws cloudfront create-invalidation \
        --distribution-id "$CF_ID" \
        --paths "/config.js" "/index.html" >/dev/null
    EOT
  }
}
