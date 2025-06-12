variable "rds_name" {
  type        = string
  description = "The name of the RDS"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS cluster will be deployed."
}

variable "db_username" {
  type        = string
  description = "Master username for the RDS database."
  sensitive   = true
}

# variable "db_password" {
#   type        = string
#   description = "Master password for the RDS database."
#   sensitive   = true
# }

variable "allowed_security_groups" {
  type        = list(string)
  description = "List of security groups allowed to access the RDS database (typically internal)."
  default     = []
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs to use for the RDS subnet group."
}

variable "tags" {
  type        = map(any)
  description = "Default tags to be assigned to all resources"
  default     = {}
}