import os
import json
import secrets
import string

import boto3
import psycopg2
from psycopg2 import sql


def generate_password(length=16):
    alphabet = (
        string.ascii_letters +
        string.digits +
        "!#$%^&*()_+-=[]{}|:,.<>?"
    )
    for c in '/@" ':
        alphabet = alphabet.replace(c, "")
    return "".join(secrets.choice(alphabet) for _ in range(length))


def lambda_handler(event, context):
    # 1) Parse input
    services = event.get("microservices")
    if not isinstance(services, list) or not services:
        raise ValueError("Missing or invalid 'microservices' list")

    # build list of all DBs to lock down (service DBs + default postgres)
    service_dbs = [f"{svc}_db" for svc in services]
    all_dbs     = service_dbs + ["postgres"]

    # 2) Load admin creds & rotation Lambda ARN
    region               = os.environ.get("AWS_REGION", "eu-central-1")
    sm                   = boto3.client("secretsmanager", region_name=region)
    admin_secret_arn     = os.environ["RDS_SECRET_ARN"]
    rotation_lambda_arn  = os.environ.get("ROTATION_LAMBDA_ARN")
    admin_val            = sm.get_secret_value(SecretId=admin_secret_arn)
    admin                = json.loads(admin_val["SecretString"])
    admin_user, admin_pass = admin["username"], admin["password"]
    host = os.environ["RDS_HOST"]

    results = []

    # 3) Connect to 'postgres' for role mgmt + revokes
    pg_conn = psycopg2.connect(
        host=host,
        dbname="postgres",
        user=admin_user,
        password=admin_pass,
        port=5432,
        sslmode="require",
        connect_timeout=5
    )
    pg_conn.autocommit = True
    pg_cur = pg_conn.cursor()

    # 4) Revoke CONNECT from PUBLIC on every DB we protect
    for db in all_dbs:
        try:
            pg_cur.execute(
                sql.SQL("REVOKE CONNECT ON DATABASE {} FROM PUBLIC")
                   .format(sql.Identifier(db))
            )
        except Exception:
            pass  # ignore if already revoked or missing

    # 5) Loop services to create/rotate roles, secrets, grants, rotation
    for svc in services:
        db_name     = f"{svc}_db"
        db_role     = f"{svc}_user"
        db_pass     = generate_password()
        secret_name = f"{svc}/db-credentials"

        try:
            # 5a) Ensure the DB exists
            pg_cur.execute(
                "SELECT 1 FROM pg_database WHERE datname = %s",
                (db_name,)
            )
            if not pg_cur.fetchone():
                raise Exception(f"Database '{db_name}' does not exist")

            # 5b) Create or rotate the role’s password
            try:
                pg_cur.execute(
                    sql.SQL("CREATE ROLE {} LOGIN PASSWORD %s")
                       .format(sql.Identifier(db_role)),
                    (db_pass,)
                )
                role_status = "created"
            except psycopg2.errors.DuplicateObject:
                pg_cur.execute(
                    sql.SQL("ALTER ROLE {} WITH PASSWORD %s")
                       .format(sql.Identifier(db_role)),
                    (db_pass,)
                )
                role_status = "rotated"

            # 5c) Persist credentials to Secrets Manager
            payload = json.dumps({
                "username": db_role,
                "password": db_pass,
                "host":     host,
                "dbname":   db_name,
                "port":     5432
            })
            try:
                sm.create_secret(Name=secret_name, SecretString=payload)
                secret_status = "created"
            except sm.exceptions.ResourceExistsException:
                sm.put_secret_value(SecretId=secret_name, SecretString=payload)
                secret_status = "updated"

            # 5d) Grant CONNECT only on its own DB
            pg_cur.execute(
                sql.SQL("GRANT CONNECT ON DATABASE {} TO {}")
                   .format(sql.Identifier(db_name), sql.Identifier(db_role))
            )

            # 5e) Schema/table/sequence grants inside the service DB
            svc_conn = psycopg2.connect(
                host=host,
                dbname=db_name,
                user=admin_user,
                password=admin_pass,
                port=5432,
                sslmode="require",
                connect_timeout=5
            )
            svc_conn.autocommit = True
            svc_cur = svc_conn.cursor()

            svc_cur.execute(
                sql.SQL("GRANT USAGE ON SCHEMA public TO {}")
                   .format(sql.Identifier(db_role))
            )
            svc_cur.execute(
                sql.SQL("GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO {}")
                   .format(sql.Identifier(db_role))
            )
            svc_cur.execute(
                sql.SQL("GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO {}")
                   .format(sql.Identifier(db_role))
            )
            svc_cur.execute(
                sql.SQL(
                  "ALTER DEFAULT PRIVILEGES IN SCHEMA public "
                  "GRANT ALL ON TABLES TO {}"
                ).format(sql.Identifier(db_role))
            )

            svc_cur.close()
            svc_conn.close()

            # 5f) Enable rotation on that secret if a rotation Lambda is provided
            if rotation_lambda_arn:
                try:
                    desc = sm.describe_secret(SecretId=secret_name)
                    if not desc.get("RotationEnabled"):
                        sm.rotate_secret(
                            SecretId=secret_name,
                            RotationLambdaARN=rotation_lambda_arn,
                            RotationRules={"AutomaticallyAfterDays": 30}
                        )
                        rotation_status = "enabled"
                    else:
                        rotation_status = "already-enabled"
                except Exception as e:
                    rotation_status = f"error: {str(e)}"
            else:
                rotation_status = "skipped"

            results.append({
                "microservice":  svc,
                "role_status":   role_status,
                "secret_status": secret_status,
                "rotation":      rotation_status
            })

        except Exception as e:
            results.append({
                "microservice": svc,
                "error":        str(e)
            })

    pg_cur.close()
    pg_conn.close()

    # 6) Fail hard if any service errored
    if any("error" in r for r in results):
        raise Exception(json.dumps({
            "status":  "error",
            "results": results
        }))

    return {
        "status":  "success",
        "results": results
    }
