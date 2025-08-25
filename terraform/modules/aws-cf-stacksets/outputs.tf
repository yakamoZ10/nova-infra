output "stack_set_names" {
  description = "Names of all CloudFormation StackSets created"
  value       = [for name in keys(aws_cloudformation_stack_set.this) : name]
}