# resource "aws_security_group" "additional" {
#   name        = var.nodes_additional_sg_name
#   vpc_id      = var.vpc_id
#   description = "Additional security group for cluster ${var.cluster_name}"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     description = "Allow traffic from VPN clients"
#     cidr_blocks = [
#       "10.150.0.0/16"
#     ]
#   }

#   tags = var.tags
# }