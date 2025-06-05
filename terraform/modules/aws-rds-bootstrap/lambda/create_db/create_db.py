import os
import boto3
import json
import psycopg2
from psycopg2 import sql


def lambda_handler(event, context):
    # Step 1: Read DB name from the input event
    microservice = event.get("microservice")
    if not microservice:
        return { "status": "error", "message": "Missing 'microservice' in input." }

    db_name = f"{microservice}_db"

    # Step 2: Get credentials from Secrets Manager
    secret_arn = os.environ["RDS_SECRET_ARN"]
    region = os.environ.get("AWS_REGION", "eu-central-1")
    secrets_client = boto3.client("secretsmanager", region_name=region)

    secret = secrets_client.get_secret_value(SecretId=secret_arn)
    secret_dict = json.loads(secret["SecretString"])

    db_host = os.environ["RDS_HOST"]
    db_user = secret_dict["username"]
    db_pass = secret_dict["password"]

    # Step 3: Connect to the RDS cluster
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

        # Step 4: Create the new database
        create_db_query = sql.SQL("CREATE DATABASE {}"
            ).format(sql.Identifier(db_name))
        cur.execute(create_db_query)
        print(f"Database '{db_name}' created successfully.")

        cur.close()
        conn.close()
        return {"status": "success", "database": db_name}

    except psycopg2.errors.DuplicateDatabase:
        print(f"Database '{db_name}' already exists.")
        return {"status": "exists", "database": db_name}

    except Exception as e:
        print(f"Error: {str(e)}")
        return {"status": "error", "message": str(e)}
