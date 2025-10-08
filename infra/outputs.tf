output "site_url" { value = "https://${var.domain_name}" }
output "api_url" { value = "${data.aws_apigatewayv2_api.api.api_endpoint}/predict" }
output "endpoint_name" { value = var.endpoint_name }
output "model_key" { value = var.model_key }
