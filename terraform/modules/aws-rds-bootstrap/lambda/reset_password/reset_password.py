import os
import json
import secrets
import string
import logging
import socket

import boto3
import psycopg2
from psycopg2 import sql

# Configure logging
glogger = logging.getLogger()
glogger.setLevel(logging.INFO)

def generate_password(length=16):
    alphabet = (
        string.ascii_letters
        + string.digits
        + "!#$%^&*()_+-=[]{}|:,.<>?"
    )
    # remove problematic characters
    alphabet = alphabet.replace('/', '').replace('@', '').replace('"', '')
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def lambda_handler(event, context):
    # Rotation step info from Secrets Manager event
    step   = event.get("Step")
    sid    = event.get("SecretId")
    token  = event.get("ClientRequestToken")
    region = os.environ.get("AWS_REGION", "eu-central-1")

    if not all([step, sid, token]):
        raise ValueError("Missing Step, SecretId or ClientRequestToken in event")

    # Initialize clients
    sm = boto3.client("secretsmanager", region_name=region)

    # Fetch master/admin credentials and DB host from environment
    master_secret_arn = os.environ["RDS_MASTER_SECRET_ARN"]
    master_val = sm.get_secret_value(SecretId=master_secret_arn)
    admin = json.loads(master_val["SecretString"])
    admin_user = admin["username"]
    admin_pass = admin["password"]
    db_host    = os.environ["RDS_HOST"]

    # Describe secret metadata and validate pending version
    metadata = sm.describe_secret(SecretId=sid)
    versions = metadata.get("VersionIdsToStages", {})
    if token not in versions or "AWSPENDING" not in versions[token]:
        raise ValueError("Invalid token or missing AWSPENDING stage")

    # Load current secret to copy fields
    current_secret = json.loads(
        sm.get_secret_value(SecretId=sid, VersionStage="AWSCURRENT")["SecretString"]
    )

    if step == "createSecret":
        # Create a new pending version if not exists
        try:
            sm.get_secret_value(SecretId=sid, VersionId=token, VersionStage="AWSPENDING")
            glogger.info("createSecret: pending version already exists")
        except sm.exceptions.ResourceNotFoundException:
            new_pw = generate_password()
            pending = current_secret.copy()
            pending["password"] = new_pw
            sm.put_secret_value(
                SecretId=sid,
                ClientRequestToken=token,
                SecretString=json.dumps(pending),
                VersionStages=["AWSPENDING"]
            )
            glogger.info("createSecret: new pending secret created")

    elif step == "setSecret":
        # Apply the new password using admin credentials
        pend = json.loads(
            sm.get_secret_value(SecretId=sid, VersionStage="AWSPENDING")["SecretString"]
        )
        svc_user = pend["username"]
        svc_pass = pend["password"]

        conn = psycopg2.connect(
            host=db_host,
            dbname="postgres",
            user=admin_user,
            password=admin_pass,
            port=5432,
            sslmode="require",
            connect_timeout=5
        )
        conn.autocommit = True
        cur = conn.cursor()
        cur.execute(
            sql.SQL("ALTER USER {} WITH PASSWORD %s").format(sql.Identifier(svc_user)),
            (svc_pass,)
        )
        cur.close()
        conn.close()
        glogger.info(f"setSecret: rotated password for {svc_user}")

    elif step == "testSecret":
        # verify network and login as service user
        pend = json.loads(
            sm.get_secret_value(SecretId=sid, VersionStage="AWSPENDING")["SecretString"]
        )
        h = pend["host"]
        dbn = pend["dbname"]
        u = pend["username"]
        p = pend["password"]

        # Network check
        glogger.info(f"Resolving {h}")
        ip = socket.gethostbyname(h)
        glogger.info(f"{h} -> {ip}, testing TCP connect...")
        sock = socket.create_connection((h, 5432), timeout=5)
        sock.close()
        glogger.info("Network reachability OK")

        # Database login test
        conn = psycopg2.connect(
            host=h,
            dbname=dbn,
            user=u,
            password=p,
            port=5432,
            sslmode="require",
            connect_timeout=5
        )
        conn.close()
        glogger.info("testSecret: login succeeded")

    elif step == "finishSecret":
        # Promote pending to current and clear pending
        curr_ver = next(v for v,st in versions.items() if "AWSCURRENT" in st)
        if curr_ver != token:
            sm.update_secret_version_stage(
                SecretId=sid,
                VersionStage="AWSCURRENT",
                MoveToVersionId=token,
                RemoveFromVersionId=curr_ver
            )
            sm.update_secret_version_stage(
                SecretId=sid,
                VersionStage="AWSPENDING",
                MoveToVersionId=curr_ver,
                RemoveFromVersionId=token
            )
            glogger.info("finishSecret: rotation complete")

    else:
        raise ValueError(f"Unknown step: {step}")

    return {"status": "success", "step": step, "secret": sid}
