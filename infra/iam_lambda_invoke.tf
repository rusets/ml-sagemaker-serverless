locals {
  lambda_role_name = element(split("/", data.aws_lambda_function.proxy.role), 1)
}

resource "aws_iam_role_policy" "lambda_invoke_sm" {
  name = "${var.project_name}-lambda-invoke-sm"
  role = local.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "InvokeSageMakerEndpoint",
      Effect   = "Allow",
      Action   = ["sagemaker:InvokeEndpoint"],
      Resource = "arn:aws:sagemaker:${var.region}:${data.aws_caller_identity.me.account_id}:endpoint/${var.endpoint_name}"
    }]
  })
}
