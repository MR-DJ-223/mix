locals {
  function_name = "${var.name}-function"
  regex = "/[^0-9a-zA-Z+]/"
  sid_name = replace(var.sid_name, local.regex, "")

  # See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html
  layers = var.is_lambda_insights_enabled ? concat(var.layers, ["arn:aws:lambda:${data.aws_region.current.name}:580247275435:layer:LambdaInsightsExtension:14"]) : var.layers

  lambda_role_arn = var.execution_role == null ? (aws_iam_role.lambda_default_execution_role[0].arn) : var.execution_role
}

data "aws_region" "current" {}

data "aws_caller_identity" "this" {
  # Use this data source to get the access to the effective Account ID,
  # User ID, and ARN in which Terraform is authorized.
}

resource "aws_lambda_function" "this" {
  function_name                  = local.function_name
  description                    = var.description
  filename                       = var.zip_file
  source_code_hash               = filebase64sha256(var.zip_file)
  handler                        = var.entrypoint_function_name
  runtime                        = var.runtime
  memory_size                    = var.memory_size
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  timeout                        = var.timeout
  layers                         = local.layers
  role                           = var.execution_role == null ? aws_iam_role.lambda_default_execution_role[0].arn : var.execution_role

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [true] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.can_access_vpc == true ? [true] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids = var.subnet_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_arn != "" && var.file_system_local_mount_path != "" ? [true] : []
    content {
      local_mount_path = var.file_system_local_mount_path
      arn              = var.file_system_arn
    }
  }

  tags = merge(var.tag_map, { Name = local.function_name })

  depends_on = [var.module_dependencies]
}

data "aws_iam_policy" "lambda_basic_execution_role" {
  arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_vpc_access_role" {
  arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy" "lambda_insights_role" {
  arn = "arn:aws-us-gov:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role" "lambda_default_execution_role" {
  count      = var.execution_role == null ? 1 : 0
  name       = "${var.name}-exec-role"
  path = "/project/"
  permissions_boundary = "arn:aws-us-gov:iam::${data.aws_caller_identity.this.account_id}:policy/vaec/project-admin"
  assume_role_policy =<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "${local.sid_name}ExecutionRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  depends_on = [var.module_dependencies]
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_attach" {
  count      = var.execution_role == null ? 1 : 0
  policy_arn = data.aws_iam_policy.lambda_basic_execution_role.arn
  role       = aws_iam_role.lambda_default_execution_role[0].name
  depends_on = [var.module_dependencies]
}

resource "aws_iam_role_policy_attachment" "additional_lambda_execution_role_attach" {
  count      = var.execution_role == null && var.use_additional_policy == true ? 1 : 0
  policy_arn = var.additional_execution_policy
  role       = aws_iam_role.lambda_default_execution_role[0].name
  depends_on = [var.module_dependencies]
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_role_attach" {
  count      = var.execution_role == null ? 1 : 0
  policy_arn = data.aws_iam_policy.lambda_vpc_access_role.arn
  role       = aws_iam_role.lambda_default_execution_role[0].name
  depends_on = [var.module_dependencies]
}

resource "aws_iam_role_policy_attachment" "lambda_insights_role_attach" {
  count      = var.execution_role == null ? 1 : 0
  policy_arn = data.aws_iam_policy.lambda_insights_role.arn
  role       = aws_iam_role.lambda_default_execution_role[0].name
  depends_on = [var.module_dependencies]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_in_days
  depends_on        = [var.module_dependencies]
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = var.name
  log_group_name = aws_cloudwatch_log_group.this.name
  depends_on     = [var.module_dependencies]
}
