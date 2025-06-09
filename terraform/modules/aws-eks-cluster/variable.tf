variable "vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS worker nodes"
  type        = list(string)
}

variable "admin_role_arn" {
  description = "Admin IAM role for aws-auth configmap"
  type        = string
}

variable "default_tags" {
  description = "Common resource tags"
  type        = map(string)
}
