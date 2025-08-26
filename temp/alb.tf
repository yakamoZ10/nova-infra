# -----------------------------------------------------
# Application Load Balancer (ALB)
# -----------------------------------------------------

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    "subnet-083d28108dfe5a2ec",
    "subnet-0e4097261682aad51"
  ]

  enable_deletion_protection = false
}

# -----------------------------------------------------
# Application Load Balancer (ALB) Listener
# -----------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pgadmin_tg.arn
  }
}

# -----------------------------------------------------
# Target Group and ALB Listener for PGADMIN
# -----------------------------------------------------
resource "aws_lb_target_group" "pgadmin_tg" {
  name        = "pgadmin-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-02b20691c9acc69ab"
  target_type = "ip"
  health_check {
    path                = "/misc/ping"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}