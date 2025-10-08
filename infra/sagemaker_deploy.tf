locals {
  ts         = replace(replace(timestamp(), ":", ""), "Z", "")
  model_name = "${var.endpoint_name}-${local.ts}"
  cfg_name   = "${local.model_name}-cfg"
  image_uri  = "763104351884.dkr.ecr.${var.region}.amazonaws.com/pytorch-inference:2.1.0-cpu-py310-ubuntu20.04-sagemaker"
}


resource "null_resource" "sm_update" {
  triggers = {
    model_key = var.model_key
    model_ver = var.model_version
    endpoint  = var.endpoint_name
    mem       = tostring(var.serverless_memory_mb)
    conc      = tostring(var.serverless_max_conc)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ACCOUNT_ID = data.aws_caller_identity.me.account_id
      PROJECT    = var.project_name
      REGION     = var.region
      ARTIFACTS  = var.artifacts_bucket
      MODEL_KEY  = var.model_key
      IMAGE_URI  = local.image_uri
      ENDPOINT   = var.endpoint_name
      CFG_NAME   = local.cfg_name
      MODEL_NAME = local.model_name
      MEM        = tostring(var.serverless_memory_mb)
      CONC       = tostring(var.serverless_max_conc)
      TS         = local.ts
    }
    command = <<EOT
set -euo pipefail

ROLE_ARN="arn:aws:iam::$${ACCOUNT_ID}:role/$${PROJECT}-sagemaker-exec"

aws sagemaker create-model \
  --model-name "$${MODEL_NAME}" \
  --primary-container '{
    "Image": "'"$${IMAGE_URI}"'",
    "Mode": "SingleModel",
    "ModelDataUrl": "s3://'"$${ARTIFACTS}"'/'"$${MODEL_KEY}"'",
    "Environment": { "APP_VERSION": "'"$${TS}"'" }
  }' \
  --execution-role-arn "$${ROLE_ARN}" >/dev/null

aws sagemaker create-endpoint-config \
  --endpoint-config-name "$${CFG_NAME}" \
  --production-variants '[
    {
      "VariantName": "All",
      "ModelName": "'"$${MODEL_NAME}"'",
      "ServerlessConfig": { "MemorySizeInMB": '"$${MEM}"', "MaxConcurrency": '"$${CONC}"' }
    }
  ]' >/dev/null

STATUS=$(aws sagemaker describe-endpoint --endpoint-name "$${ENDPOINT}" --query 'EndpointStatus' --output text 2>/dev/null || echo Missing)

if [ "$${STATUS}" = "Creating" ] || [ "$${STATUS}" = "Updating" ]; then
  aws sagemaker wait endpoint-in-service --endpoint-name "$${ENDPOINT}"
  STATUS=InService
fi

if [ "$${STATUS}" = "Failed" ]; then
  aws sagemaker delete-endpoint --endpoint-name "$${ENDPOINT}" >/dev/null || true
  aws sagemaker wait endpoint-deleted --endpoint-name "$${ENDPOINT}"
  STATUS=Missing
fi

if [ "$${STATUS}" = "Missing" ]; then
  aws sagemaker create-endpoint --endpoint-name "$${ENDPOINT}" --endpoint-config-name "$${CFG_NAME}" >/dev/null
else
  aws sagemaker update-endpoint --endpoint-name "$${ENDPOINT}" --endpoint-config-name "$${CFG_NAME}" >/dev/null
fi

aws sagemaker wait endpoint-in-service --endpoint-name "$${ENDPOINT}"
EOT
  }
}
