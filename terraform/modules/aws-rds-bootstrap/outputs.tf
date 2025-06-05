output "state_machine_arn" {
  value       = aws_sfn_state_machine.bootstrap_db.arn
  description = "ARN of the created Step Function."
}
