import os
import boto3
import json
import psycopg2
from psycopg2 import sql

def lambda_handler(event, context):
    db_names = event.get("microservices")
    if not db_names or not isinstance(db_names, list):
        raise Exception("Missing or invalid 'microservices' list in input.")

    secret_arn = os.environ["RDS_SECRET_ARN"]
    region = os.environ.get("AWS_REGION", "eu-central-1")
    secrets_client = boto3.client("secretsmanager", region_name=region)

    try:
        secret = secrets_client.get_secret_value(SecretId=secret_arn)
        secret_dict = json.loads(secret["SecretString"])
        db_host = os.environ["RDS_HOST"]
        db_user = secret_dict["username"]
        db_pass = secret_dict["password"]
    except Exception as e:
        raise Exception(f"Secrets retrieval failed: {str(e)}")

    try:
        conn = psycopg2.connect(
            host=db_host,
            user=db_user,
            password=db_pass,
            dbname="postgres",
            port=5432,
            sslmode='require'
        )
        conn.autocommit = True
        cur = conn.cursor()
    except Exception as e:
        raise Exception(f"Database connection failed: {str(e)}")

    results = []
    has_failure = False

    for name in db_names:
        db_name = f"{name}_db"
        try:
            cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db_name,))
            if cur.fetchone():
                results.append({
                    "name": db_name,
                    "status": "exists",
                    "message": f"Database '{db_name}' already exists."
                })
            else:
                cur.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(db_name)))
                results.append({
                    "name": db_name,
                    "status": "created",
                    "message": f"Database '{db_name}' created successfully."
                })
        except Exception as e:
            has_failure = True
            results.append({
                "name": db_name,
                "status": "failed",
                "message": str(e)
            })

    cur.close()
    conn.close()

    if has_failure:
        raise Exception(json.dumps({
            "status": "error",
            "message": "One or more databases failed.",
            "results": results
        }))

    return {
        "status": "success",
        "results": results
    }
