############################################
# IAM Policy — Lambda → SageMaker Endpoint
# Grants Lambda execution role permission to invoke the endpoint
############################################

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


############################################
# IAM Policy Attachment — SageMaker Exec Role
# Grants SageMaker read-only access to ECR (pull images)
############################################

resource "aws_iam_role_policy_attachment" "sagemaker_exec_ecr_ro" {
  role       = data.aws_iam_role.sagemaker_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
