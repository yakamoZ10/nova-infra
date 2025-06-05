import boto3
import os
import json
import secrets
import string

def generate_password(length=16):
    alphabet = ''.join(c for c in (string.ascii_letters + string.digits + "!#$%^&*()_+-=[]{}|:,.<>?") if c not in '/@" ')
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def lambda_handler(event, context):
    instance_id = os.environ["RDS_INSTANCE_ID"]  # ✅ NEW
    secret_arn = os.environ["SECRET_ARN"]
    region = os.environ.get("AWS_REGION", "eu-central-1")

    secrets_client = boto3.client("secretsmanager", region_name=region)
    rds_client = boto3.client("rds", region_name=region)

    try:
        # Step 1: Get current secret
        secret = secrets_client.get_secret_value(SecretId=secret_arn)
        secret_dict = json.loads(secret["SecretString"])
        username = secret_dict["username"]

        # Step 2: Generate new password
        new_password = generate_password()

        # Step 3: Modify RDS instance master password
        rds_client.modify_db_instance(
            DBInstanceIdentifier=instance_id,
            MasterUserPassword=new_password,
            ApplyImmediately=True
        )

        # Step 4: Update Secrets Manager
        secret_dict["password"] = new_password
        secrets_client.put_secret_value(
            SecretId=secret_arn,
            SecretString=json.dumps(secret_dict)
        )

        return {
            "status": "success",
            "message": f"🔁 Password for {username} rotated and stored in Secrets Manager"
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }