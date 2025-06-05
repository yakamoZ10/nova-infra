import os
import boto3
import json
import psycopg2
from psycopg2 import sql
import secrets
import string

def generate_password(length=16):
    alphabet = ''.join(c for c in (string.ascii_letters + string.digits + "!#$%^&*()_+-=[]{}|:,.<>?") if c not in '/@" ')
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def lambda_handler(event, context):
    microservice = event.get("microservice")
    if not microservice or not isinstance(microservice, str):
        return { "status": "error", "message": "Missing or invalid 'microservice' in input." }

    db_name     = f"{microservice}_db"
    db_user     = f"{microservice}_user"
    db_pass     = generate_password()
    secret_name = f"{microservice}/db-credentials"

    secret_arn  = os.environ["RDS_SECRET_ARN"]
    region      = os.environ.get("AWS_REGION", "eu-central-1")
    secrets_client = boto3.client("secretsmanager", region_name=region)

    # Get admin credentials
    secret = secrets_client.get_secret_value(SecretId=secret_arn)
    secret_dict = json.loads(secret["SecretString"])
    admin_user = secret_dict["username"]
    admin_pass = secret_dict["password"]
    db_host    = os.environ["RDS_HOST"]

    try:
        conn = psycopg2.connect(
            host=db_host,
            user=admin_user,
            password=admin_pass,
            dbname=db_name,
            port=5432,
            sslmode='require'
        )
        conn.autocommit = True
        cur = conn.cursor()

        # Check if user exists
        cur.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", (db_user,))
        if cur.fetchone():
            print(f"ℹ️ User '{db_user}' already exists. Updating password...")
            cur.execute(
                sql.SQL("ALTER USER {} WITH PASSWORD %s").format(sql.Identifier(db_user)),
                (db_pass,)
            )
            print(f"🔁 Updated password for user '{db_user}'")
        else:
            cur.execute(
                sql.SQL("CREATE ROLE {} LOGIN PASSWORD %s").format(sql.Identifier(db_user)),
                (db_pass,)
            )
            print(f"✅ Created user '{db_user}'")

        # Grant privileges (idempotent if already granted)
        cur.execute(sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {};")
            .format(sql.Identifier(db_name), sql.Identifier(db_user)))

        cur.close()
        conn.close()

        # Store or update secret
        secret_value = {
            "username": db_user,
            "password": db_pass,
            "host": db_host,
            "dbname": db_name,
            "port": 5432
            
        }

        try:
            secrets_client.put_secret_value(
                SecretId=secret_name,
                SecretString=json.dumps(secret_value)
            )
            print(f"🔁 Updated existing secret '{secret_name}'.")
        except secrets_client.exceptions.ResourceNotFoundException:
            secrets_client.create_secret(
                Name=secret_name,
                SecretString=json.dumps(secret_value)
            )
            print(f"✅ Created new secret '{secret_name}'.")

        return {
            "status": "success",
            "user": db_user,
            "secret": secret_name
        }

    except Exception as e:
        print(f"❌ Error: {e}")
        return { "status": "error", "message": str(e) }
