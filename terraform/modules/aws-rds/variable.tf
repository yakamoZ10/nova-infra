
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS cluster will be deployed."
}

variable "db_username" {
  type        = string
  description = "Master username for the RDS database."
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Master password for the RDS database."
  sensitive   = true
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the RDS database (typically internal)."
  default     = ["10.0.0.0/16"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to use for the RDS subnet group."
}

variable "rds_name"{

  type = string
  description = "The name of the RDS"
}