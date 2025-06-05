
resource "aws_db_instance" "postgres" {
  identifier             = var.rds_name
  engine                 = "postgres"
  engine_version         = "16.6"
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 7
  backup_window          = "04:00-05:00"
  storage_encrypted      = true
}

resource "aws_db_subnet_group" "db" {
  name       = "db-subnet-group"
  subnet_ids =  var.private_subnet_ids

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-"
  description = "Allow database traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
