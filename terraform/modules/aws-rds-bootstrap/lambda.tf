# resource "null_resource" "install_reset_password_deps" {
#   provisioner "local-exec" {
#     interpreter = ["PowerShell", "-Command"]
#     command     = <<EOT
#       Write-Host "Installing boto3 into lambda\\reset_password..."
#       Remove-Item -Recurse -Force "${replace(path.module, "/", "\\")}\\lambda\\reset_password\\boto3*" -ErrorAction SilentlyContinue
#       Remove-Item -Recurse -Force "${replace(path.module, "/", "\\")}\\lambda\\reset_password\\botocore*" -ErrorAction SilentlyContinue
#       & "C:\\Python38\\python.exe" -m pip install boto3 -t "${replace(path.module, "/", "\\")}\\lambda\\reset_password"
#       Write-Host "Contents of reset_password folder:"
#       Get-ChildItem "${replace(path.module, "/", "\\")}\\lambda\\reset_password"
#     EOT
#   }

#   triggers = {
#      folder_hash = filesha256("${path.module}/lambda/reset_password/reset_password.py")
#   }
# }

data "archive_file" "create_db_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/create_db"
  output_path = "${path.module}/lambda/create_db.zip"

}

data "archive_file" "reset_password_zip" {

  # depends_on  = [null_resource.install_reset_password_deps]

  type        = "zip"
  source_dir  = "${path.module}/lambda/reset_password" 
  output_path = "${path.module}/lambda/reset_password2.zip"

}


data "archive_file" "create_user_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/create_user"
  output_path = "${path.module}/lambda/create_user.zip"
}

