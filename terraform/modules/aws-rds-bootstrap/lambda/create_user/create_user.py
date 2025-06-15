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
    services = event.get("microservices")
    if not services or not isinstance(services, list):
        raise Exception("Missing or invalid 'microservices' list in input.")

    secret_arn = os.environ["RDS_SECRET_ARN"]
    region     = os.environ.get("AWS_REGION", "eu-central-1")
    db_host    = os.environ["RDS_HOST"]
    secrets_client = boto3.client("secretsmanager", region_name=region)

    # Get admin credentials
    try:
        secret = secrets_client.get_secret_value(SecretId=secret_arn)
        secret_dict = json.loads(secret["SecretString"])
        admin_user = secret_dict["username"]
        admin_pass = secret_dict["password"]
    except Exception as e:
        raise Exception(f"Secrets retrieval failed: {str(e)}")

    # Connect once to postgres
    try:
        conn = psycopg2.connect(
            host=db_host,
            user=admin_user,
            password=admin_pass,
            dbname="postgres",
            port=5432,
            sslmode='require',
            connect_timeout=5
        )
        conn.autocommit = True
        cur = conn.cursor()
    except Exception as e:
        raise Exception(f"Database connection failed: {str(e)}")

    results = []

    for svc in services:
        db_name     = f"{svc}_db"
        db_user     = f"{svc}_user"
        db_pass     = generate_password()
        secret_name = f"{svc}/db-credentials"

        try:
            # Check if target DB exists
            cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
            if not cur.fetchone():
                raise Exception(f"Database '{db_name}' does not exist")

            # Check if user exists
            cur.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", (db_user,))
            if cur.fetchone():
                cur.execute(
                    sql.SQL("ALTER USER {} WITH PASSWORD %s").format(sql.Identifier(db_user)),
                    (db_pass,)
                )
                user_status = "updated"
            else:
                cur.execute(
                    sql.SQL("CREATE ROLE {} LOGIN PASSWORD %s").format(sql.Identifier(db_user)),
                    (db_pass,)
                )
                user_status = "created"

            # Grant privileges
            cur.execute(
                sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {}").format(
                    sql.Identifier(db_name), sql.Identifier(db_user)
                )
            )

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
                secret_status = "updated"
            except secrets_client.exceptions.ResourceNotFoundException:
                secrets_client.create_secret(
                    Name=secret_name,
                    SecretString=json.dumps(secret_value)
                )
                secret_status = "created"

            results.append({
                "name": svc,
                "status": "success",
                "user": user_status,
                "secret": secret_status
            })

        except Exception as e:
            results.append({
                "name": svc,
                "status": "failed",
                "message": str(e)
            })

    cur.close()
    conn.close()

    # Final evaluation
    if any(r["status"] == "failed" for r in results):
        raise Exception(json.dumps({
            "status": "error",
            "message": "One or more users failed.",
            "results": results
        }))

    return {
        "status": "success",
        "results": results
    }
