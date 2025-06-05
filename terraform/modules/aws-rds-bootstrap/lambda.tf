resource "null_resource" "install_reset_password_deps" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOT
      Write-Host "Installing boto3 into lambda\\reset_password..."
      Remove-Item -Recurse -Force "${replace(path.module, "/", "\\")}\\lambda\\reset_password\\boto3*" -ErrorAction SilentlyContinue
      pip install boto3 -t "${replace(path.module, "/", "\\")}\\lambda\\reset_password"
      Write-Host "Contents of reset_password folder:"
      Get-ChildItem "${replace(path.module, "/", "\\")}\\lambda\\reset_password"
    EOT
  }

  triggers = {
     folder_hash = filesha256("${path.module}/lambda/reset_password/reset_password.py")
  }
}

data "archive_file" "create_db_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/create_db"
  output_path = "${path.module}/lambda/create_db.zip"

}

data "archive_file" "reset_password_zip" {

  depends_on  = [null_resource.install_reset_password_deps]

  type        = "zip"
  source_dir  = "${path.module}/lambda/reset_password" 
  output_path = "${path.module}/lambda/reset_password2.zip"

}

  resource "aws_s3_object" "create_db_lambda_zip" {
  bucket = "nova-devops-1-terraform-state"
  key    = "lambdas/create_db.zip"
  source = data.archive_file.create_db_zip.output_path
  etag   = filemd5(data.archive_file.create_db_zip.output_path)

}

resource "aws_s3_object" "reset_password_lambda_zip" {

  depends_on  = [data.archive_file.reset_password_zip]

  bucket = "nova-devops-1-terraform-state"
  key    = "lambdas/reset_password2.zip"
  source = data.archive_file.reset_password_zip.output_path
  source_hash = data.archive_file.reset_password_zip.output_base64sha256
   
}


resource "aws_s3_object" "create_user_lambda_zip" {
  bucket = "nova-devops-1-terraform-state"
  key    = "lambdas/create_user.zip"
  source = data.archive_file.create_user_zip.output_path
  etag   = filemd5(data.archive_file.create_user_zip.output_path)
}

data "archive_file" "create_user_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/create_user"
  output_path = "${path.module}/lambda/create_user.zip"
}

resource "aws_s3_object" "psycopg2_layer_zip" {
  bucket = "nova-devops-1-terraform-state"
  key    = "layers/psycopg2-layer-py38.zip"
  source = "${path.module}/lambda/psycopg2-layer-py38.zip"
  etag   = filemd5("${path.module}/lambda/psycopg2-layer-py38.zip")
}

