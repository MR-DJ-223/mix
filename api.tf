variable "name" {
  type        = string
  description = "The name of the lambda function. Note, the function name must be unique within the same region."
  default     = "default_function_name"
}

variable "sid_name" {
  type        = string
  description = "SID name."
}

variable "description" {
  type        = string
  description = "Description of the lambda"
  default     = ""
}

variable "zip_file" {
  type        = string
  description = "The path and filename of the zip file containing the source code for the lambda on the local filesystem."
}

# FIXME: Add S3 deployment functionality

variable "runtime" {
  type        = string
  description = "Runtime to use for this lambda. For example, python3.7, java11, etc. See https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html"
}

variable "memory_size" {
  type        = number
  description = "Memory size for the lambda. Default is 128 MB."
  default     = 128
}

variable "entrypoint_function_name" {
  type        = string
  description = "The entrypoint function name for the lambda"
}

variable "environment_variables" {
  type        = map(string)
  description = "A map of key-value pairs representing environment variables used by the lambda."
  default     = {}
}

variable "publish" {
  type        = bool
  description = "A boolean to decide if updates are published as a new version."
  default     = false
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The number of reserved concurrent executions for the lambda. A value of 0 effectively disables the lambda. A value of -1 removes all concurrency limits."
  default     = -1
}

variable "timeout" {
  type        = number
  description = "The number of seconds the lambda has to finish."
  default     = 30
}

variable "layers" {
  type        = list(string)
  description = "List of Layer ARNs."
  default     = []
}

variable "can_access_vpc" {
  type        = bool
  description = "A boolean flag to determine whether the Lambda can access resources within a VPC."
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The ID for the VPC to associate the Lambda with (ie. vpc-xxxxxxx). If the VPC ID is not provided, "
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security group ids from the VPC to associate with the Lambda."
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet ids from the VPC to associate with the Lambda. Typically they should be private subnet ids."
  default     = []
}

variable "subnet_filter" {
  type        = string
  description = "A filter pattern used for matching subnets. For example, use 'private-*' to match all of the subnets in the VPC tagged with a tag that starts with the string 'private-'."
  default     = ""
}

variable "execution_role" {
  type        = string
  description = "The ARN for a client created execution role to be used by the Lambda. If this value is not set by the client, a default execution role will be used. Note, if using a client created execution role make sure to add policies for VPC access and CloudWatch Lambda Insights as necessary. In short, if the client provides their own execution role it is assumed to have everything required."
  default     = null
}

variable "use_additional_policy" {
  type    = bool
  default = false
}

variable "additional_execution_policy" {
  type        = string
  description = "Role to add to default role."
  default     = null
}

variable "is_lambda_insights_enabled" {
  type        = bool
  description = "A boolean to determine whether CloudWatch Lambda Insights are enabled. Cost is ~$2.40 per month per function ($0.30 per metric for first 10,000 metrics * 8 metrics = $2.40; Note every function reports 8 metrics.)"
  default     = false
}

variable "log_retention_in_days" {
  type        = string
  description = "Number of days to retain cloud watch log"
  default     = 14
}

variable "file_system_arn" {
  type        = string
  description = "An ARN value for an EFS volume."
  default     = ""
}

variable "file_system_local_mount_path" {
  type        = string
  description = "The path where the lambda will access the volume."
  default     = ""
}

variable "tag_map" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "module_dependencies" {
  type        = any
  description = "Module dependencies"
  default     = null
}