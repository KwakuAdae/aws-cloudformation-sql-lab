#!/usr/bin/env python3
"""Run SQL against the lab's Aurora PostgreSQL cluster through the RDS Data API.

The Data API runs one statement per call, so this script splits files into statements,
runs them in order, and prints query results as tables.

Examples
  python3 scripts/run_sql.py -f sql/01-schema.sql -f sql/02-seed-data.sql
  python3 scripts/run_sql.py -q "SELECT country, COUNT(*) FROM customers GROUP BY country"
  python3 scripts/run_sql.py -f sql/lessons/03-joins.sql

Connection details are read from the CloudFormation stack outputs (default stack: sql-lab).
"""
import argparse
import os
import sys
import time


def split_statements(sql):
    """Split SQL text into statements on ';', ignoring semicolons in quotes and comments."""
    statements, current = [], []
    i, n = 0, len(sql)
    in_single = in_double = False
    while i < n:
        ch = sql[i]
        nxt = sql[i + 1] if i + 1 < n else ""
        if in_single:
            current.append(ch)
            if ch == "'":
                if nxt == "'":           # escaped quote ''
                    current.append(nxt)
                    i += 1
                else:
                    in_single = False
        elif in_double:
            current.append(ch)
            if ch == '"':
                in_double = False
        elif ch == "-" and nxt == "-":     # line comment: skip to end of line
            while i < n and sql[i] != "\n":
                i += 1
            current.append("\n")
        elif ch == "/" and nxt == "*":     # block comment
            end = sql.find("*/", i + 2)
            i = n if end == -1 else end + 1
            current.append(" ")
        elif ch == "'":
            in_single = True
            current.append(ch)
        elif ch == '"':
            in_double = True
            current.append(ch)
        elif ch == ";":
            statements.append("".join(current))
            current = []
        else:
            current.append(ch)
        i += 1
    statements.append("".join(current))
    return [s.strip() for s in statements if s.strip()]


def field_value(field):
    """Convert one Data API field dict to a display string."""
    if field.get("isNull"):
        return "NULL"
    for key in ("stringValue", "longValue", "doubleValue", "booleanValue"):
        if key in field:
            return str(field[key])
    if "arrayValue" in field:
        return str(field["arrayValue"])
    if "blobValue" in field:
        return "<blob>"
    return ""


def format_table(columns, rows):
    """Render rows as an aligned text table like psql."""
    widths = [len(c) for c in columns]
    for row in rows:
        widths = [max(w, len(v)) for w, v in zip(widths, row)]
    line = lambda vals: " | ".join(v.ljust(w) for v, w in zip(vals, widths))
    out = [line(columns), "-+-".join("-" * w for w in widths)]
    out += [line(r) for r in rows]
    out.append(f"({len(rows)} row{'s' if len(rows) != 1 else ''})")
    return "\n".join(out)


def execute(client, conn, sql, retries=12):
    """Run one statement, waiting for the database to resume if it was auto-paused."""
    for attempt in range(retries):
        try:
            return client.execute_statement(sql=sql, includeResultMetadata=True, **conn)
        except client.exceptions.DatabaseResumingException:
            if attempt == 0:
                print("   (database is resuming from auto-pause, this can take ~15-30 seconds...)", file=sys.stderr)
            time.sleep(5)
    raise RuntimeError("Database did not resume in time; try again")


def describe(result):
    if "columnMetadata" in result and result.get("records") is not None:
        columns = [c.get("label") or c.get("name") for c in result["columnMetadata"]]
        rows = [[field_value(f) for f in rec] for rec in result["records"]]
        return format_table(columns, rows)
    return f"OK ({result.get('numberOfRecordsUpdated', 0)} rows affected)"


def stack_outputs(stack_name, region):
    import boto3
    cfn = boto3.client("cloudformation", region_name=region)
    outputs = cfn.describe_stacks(StackName=stack_name)["Stacks"][0]["Outputs"]
    return {o["OutputKey"]: o["OutputValue"] for o in outputs}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("-f", "--file", action="append", default=[], help="SQL file to run (repeatable)")
    parser.add_argument("-q", "--query", action="append", default=[], help="SQL text to run (repeatable)")
    parser.add_argument("--stack-name", default=os.environ.get("STACK_NAME", "sql-lab"))
    parser.add_argument("--region", default=os.environ.get("AWS_REGION", "us-east-1"))
    parser.add_argument("--continue-on-error", action="store_true", help="keep going after a failed statement")
    args = parser.parse_args(argv)
    if not args.file and not args.query:
        parser.error("give at least one --file or --query")

    import boto3
    out = stack_outputs(args.stack_name, args.region)
    conn = {"resourceArn": out["ClusterArn"], "secretArn": out["SecretArn"], "database": out["DatabaseName"]}
    client = boto3.client("rds-data", region_name=args.region)

    sources = [(path, open(path, encoding="utf-8").read()) for path in args.file]
    sources += [("query", q) for q in args.query]
    failures = 0
    for name, text in sources:
        statements = split_statements(text)
        print(f"\n=== {name}: {len(statements)} statement(s) ===")
        for stmt in statements:
            preview = " ".join(stmt.split())
            print(f"\n> {preview[:100]}{'...' if len(preview) > 100 else ''}")
            try:
                print(describe(execute(client, conn, stmt)))
            except client.exceptions.BadRequestException as err:
                failures += 1
                print(f"ERROR: {err.response['Error']['Message']}")
                if not args.continue_on_error:
                    return 1
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
