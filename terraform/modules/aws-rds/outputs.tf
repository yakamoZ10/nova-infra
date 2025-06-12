output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "rds_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_instance_id" {
  value = aws_db_instance.postgres.identifier
}

output "rds_instance_arn" {
  value = aws_db_instance.postgres.arn
}

output "rds_host" {
  value = aws_db_instance.postgres.address
}
