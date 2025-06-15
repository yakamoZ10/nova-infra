variable "microservices" {
  type        = list(string)
  description = "Name of the microservice (used to prefix resources)."
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Lambda VPC access."
}

variable "rds_sg_id" {
  type        = string
  description = "Security group ID used by the RDS cluster (applied to Lambda too)."
}

variable "rds_host" {
  type        = string
  description = "RDS cluster endpoint for connection."
}

variable "rds_secret_arn" {
  type        = string
  description = "Secrets Manager ARN for DB credentials."
}

variable "rds_instance_id" {
  type        = string
  description = "ID of the standard RDS instance (used in reset password Lambda)."
}

variable "rds_instance_arn" {
  type        = string
  description = "Full ARN of the RDS instance"
}

variable "lambda_s3_bucket" {
  type        = string
  description = "S3 bucket storing the Lambda zip files."
}

variable "lambda_create_zip" {
  type        = string
  description = "S3 key (path) to the create DB Lambda zip."
}

variable "lambda_create_user_zip" {
  type        = string
  description = "S3 key (path) to the create DB Lambda zip."
}


variable "lambda_reset_zip" {
  type        = string
  description = "S3 key (path) to the reset password Lambda zip."
}

variable "lambda_layer_arn" {
  type        = string
  description = "Optional ARN for Lambda Layer (e.g., psycopg2)."
  default     = ""
}

variable "trigger_execution" {
  description = "Whether to start an execution after deploy"
  type        = bool
  default     = false
}


variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS cluster will be deployed."
}
