# Troubleshooting

## CloudFormation

First check: **CloudFormation → sql-lab → Events**. The first `CREATE_FAILED` row has the real reason.

```bash
aws cloudformation describe-stack-events --stack-name sql-lab \
  --query "StackEvents[?contains(ResourceStatus,'FAILED')].[LogicalResourceId,ResourceStatusReason]" --output table
```

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Cannot find version 16.6 for aurora-postgresql` | That minor version isn't offered in your region | List versions: `aws rds describe-db-engine-versions --engine aurora-postgresql --query 'DBEngineVersions[].EngineVersion'`. Pick 16.3 or later and pass `--parameter-overrides EngineVersion=<version>` |
| `MinCapacity 0 is not supported` / auto-pause error | Engine version too old for scale-to-zero | Use 16.3+ (or 15.7+ / 14.12+ / 13.15+), or set `MinCapacity=0.5` |
| `ROLLBACK_COMPLETE` and you can't update | First create failed. Stacks in this state can only be deleted | `aws cloudformation delete-stack --stack-name sql-lab`, fix the cause, deploy again |
| `No updates are to be performed` | Template and parameters are unchanged | Not an error. The script passes `--no-fail-on-empty-changeset` |
| `The CIDR '10.20.0.0/16' conflicts` | Overlaps a VPC you're peering with | `--parameter-overrides VpcCidr=10.30.0.0/16` |
| Delete stuck on `DbCluster` | Deletion protection was turned on manually | RDS console → Modify → untick *Deletion protection*, then delete again |
| `AccessDenied` creating resources | Missing IAM permissions | You need CloudFormation, RDS, EC2, Secrets Manager (and `rds-data` to query) |

## Data API and Query Editor

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `DatabaseResumingException` | Database auto-paused after 10 idle minutes | Wait 15–30 s and retry (`run_sql.py` retries automatically) |
| `HttpEndpoint is not enabled` | Data API off | Template sets `EnableHttpEndpoint: true`. Check the stack finished, or enable it in RDS → Modify → *RDS Data API* |
| `BadRequestException: ... multiple statements` | Sent several statements in one CLI call | Use `scripts/run_sql.py`, which splits files into single statements |
| `relation "customers" does not exist` | Tables not created yet | `./scripts/02-load-data.sh` |
| `duplicate key value violates unique constraint` | Ran an INSERT twice (e.g. lesson 6) | Reset with `./scripts/02-load-data.sh` |
| `AccessDeniedException` on `rds-data` / `secretsmanager:GetSecretValue` | Your IAM identity can't use the Data API or read the secret | Attach `AmazonRDSDataFullAccess` (lab) or a scoped policy |
| `Stack with id sql-lab does not exist` from scripts | Different stack name or region | `export STACK_NAME=... AWS_REGION=...` before running scripts |
| `ModuleNotFoundError: No module named 'boto3'` | Python deps not installed | `pip install -r requirements.txt` |

## Local Docker

| Symptom | Fix |
|---------|-----|
| `port 5432 is already allocated` | Another PostgreSQL is running. Stop it, or change the port to `"5433:5432"` in `docker-compose.yml` |
| Tables are missing | Init scripts only run on first start: `docker compose down -v && docker compose up -d` |
