resource "null_resource" "trigger_execution" {
  count = var.trigger_execution ? 1 : 0

  triggers = {
    microservice = join(",", var.microservices)
  }

  depends_on = [aws_sfn_state_machine.bootstrap_db,
  
  # Ensure Lambda role has all policies before executing Step Function
    aws_iam_role_policy_attachment.attach_step_role,
    aws_iam_role_policy_attachment.vpc_access_attach,
    aws_iam_role_policy_attachment.basic_exec,
    aws_iam_role_policy_attachment.rds_modify_attach,
    aws_iam_role_policy_attachment.secrets_policy_attach
    
    ]

provisioner "local-exec" {
  interpreter = ["bash", "-lc"]
  command     = <<-EOT
    EXEC_NAME="bootstrap-$(date +%Y%m%d%H%M%S)"
    aws stepfunctions start-execution \
      --region eu-central-1 \
      --state-machine-arn "${aws_sfn_state_machine.bootstrap_db.arn}" \
      --name "$EXEC_NAME" \
      --input '${jsonencode({ microservices = var.microservices })}'
  EOT
}
}

resource "aws_sfn_state_machine" "bootstrap_db" {
  name     = "bootstrap-db"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Create DB and Create User",
    StartAt = "CreateDatabase",
    States = {
      CreateDatabase = {
        Type     = "Task",
        Resource = aws_lambda_function.create_db.arn,
        ResultPath = "$.db_result",
        Next     = "CreateUser",
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            Next        = "Fail"
          }
        ]
      },
      CreateUser = {
        Type     = "Task",
        Resource = aws_lambda_function.create_user.arn,
        InputPath = "$",
        Next     = "Succeed",
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            Next        = "Fail"
          }
        ]
      },
      Succeed = {
        Type = "Succeed"
      },
      Fail = {
        Type = "Fail"
      }
    }
  })
}

resource "aws_iam_role" "step_function_role" {
  name = "bootstrap-step-role-db"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "states.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_vpc_access" {
  name = "lambda-vpc-access-db"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_access_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_vpc_access.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role-db"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "invoke_lambdas" {
  name   = "bootstrap-invoke-lambdas-db"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["lambda:InvokeFunction"],
      Resource = [
        aws_lambda_function.create_db.arn,
        aws_lambda_function.reset_password.arn,
        aws_lambda_function.create_user.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_step_role" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.invoke_lambdas.arn
}



resource "aws_iam_policy" "lambda_s3_access" {
  name = "lambda-s3-access-db"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = "arn:aws:s3:::nova-devops-1-terraform-state/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}



resource "aws_lambda_layer_version" "psycopg2" {
  layer_name          = "psycopg2"
  compatible_runtimes = ["python3.8"]
  filename            =  "${path.module}/lambda/psycopg2-layer-py38.zip"
  source_code_hash    =  filebase64sha256("${path.module}/lambda/psycopg2-layer-py38.zip")
  description         = "Layer with psycopg2-binary for PostgreSQL access"
}



resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Create databases for each Microserivce

resource "aws_lambda_function" "create_db" {
  function_name = "create-db-db"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "create_db.lambda_handler"
  runtime       = "python3.8"

  filename         = data.archive_file.create_db_zip.output_path
  source_code_hash = data.archive_file.create_db_zip.output_base64sha256


  environment {
    variables = {
      RDS_HOST       = var.rds_host
      RDS_SECRET_ARN = var.rds_secret_arn
    }
  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = [aws_lambda_layer_version.psycopg2.arn]

  timeout = 40
}

# Create users for each Microservice database

resource "aws_lambda_function" "create_user" {
  function_name = "create-user-db"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "create_user.lambda_handler"
  runtime       = "python3.8"

  filename         = data.archive_file.create_user_zip.output_path
  source_code_hash = data.archive_file.create_user_zip.output_base64sha256

  environment {
    variables = {
      RDS_HOST       = var.rds_host
      RDS_SECRET_ARN = var.rds_secret_arn
      ROTATION_LAMBDA_ARN = aws_lambda_function.reset_password.arn
    }
  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = [aws_lambda_layer_version.psycopg2.arn]
  timeout = 45
}


# Reset RDS Password Lambda

resource "aws_lambda_function" "reset_password" {
  function_name = "reset-password-db"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "reset_password.lambda_handler"
  runtime       = "python3.8"

  
  filename         = data.archive_file.reset_password_zip.output_path
  source_code_hash = data.archive_file.reset_password_zip.output_base64sha256



  environment {
  variables = {

    RDS_MASTER_SECRET_ARN =  var.rds_secret_arn 
    RDS_HOST               = var.rds_host            
   
    }

  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
  
  layers = [aws_lambda_layer_version.psycopg2.arn]
  timeout = 40
}

resource "aws_iam_policy" "lambda_rds_modify" {
  name = "lambda-rds-modify-db"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:ModifyDBInstance"
        ],
        Resource = var.rds_instance_arn
      }
    ]
  })
}

#Resource = "arn:aws:rds:eu-central-1:340752798883:db:*"

resource "aws_iam_role_policy_attachment" "rds_modify_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_rds_modify.arn
}

resource "aws_iam_policy" "lambda_secrets_access" {
  name = "lambda-secrets-access-db"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue"
        ],
        Resource = var.rds_secret_arn
      },
            {
        Effect = "Allow",
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecretVersionStage"
        ],
        Resource = "arn:aws:secretsmanager:eu-central-1:340752798883:secret:*/*"
        
         },
       {
          Effect = "Allow",
          Action = [
              "lambda:InvokeFunction"
        ],
        Resource = aws_lambda_function.reset_password.arn
       }
     ]  
  })
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}



resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = var.vpc_id

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lambda_permission" "allow_secretsmanager" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reset_password.function_name
  principal     = "secretsmanager.amazonaws.com"
}