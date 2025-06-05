
output "state_machine_arns" {
  value = {
    for k, mod in module.rds_bootstrap : k => mod.state_machine_arn
  }
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_instance_id" {
  value = module.rds.rds_instance_id
}


output "rds_host" {
  value = module.rds.rds_host
}


output "rds_instance_arn" {
  value = module.rds.rds_instance_arn
}

