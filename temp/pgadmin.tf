
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "pg-admin"
}

resource "aws_ecs_task_definition" "pgadmin" {
  family                   = "pgadmin"
  cpu                      = "256"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn


  container_definitions = jsonencode([
    {
      name      = "pgadmin"
      image     = "dpage/pgadmin4"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      environment = [
        {
          name  = "PGADMIN_DEFAULT_EMAIL"
          value = "ardindd@gmail.com"
        },
        {
          name  = "PGADMIN_DEFAULT_PASSWORD"
          value = "R7?A2gv1SXhTt"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/pgadmin"
          awslogs-region        = "eu-central-1"
          awslogs-stream-prefix = "pgadmin" # container name or any identifier
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO - http://localhost:80/misc/ping || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }


  ])

  depends_on = [
    aws_cloudwatch_log_group.pgadmin
  ]
}

resource "aws_cloudwatch_log_group" "pgadmin" {
  name              = "/aws/ecs/pgadmin"
  retention_in_days = 7
}

resource "aws_ecs_service" "pgadmin" {
  name                    = "pgadmin"
  cluster                 = aws_ecs_cluster.ecs_cluster.id
  task_definition         = aws_ecs_task_definition.pgadmin.arn
  desired_count           = 1
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true
  force_new_deployment    = true
  enable_execute_command  = true

  network_configuration {
    subnets = [
      "subnet-09288d3d2cc43a49f",
      "subnet-096564862ab12724e"
    ]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.pgadmin_tg.arn
    container_name   = "pgadmin"
    container_port   = 80
  }


  depends_on = [
    aws_cloudwatch_log_group.pgadmin
  ]
}