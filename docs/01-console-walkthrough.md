# Console Walkthrough: Deploy and Query with Only the AWS Console

## 1. Create the stack

1. Open **CloudFormation → Stacks → Create stack → With new resources (standard)**.
2. **Prepare template:** *Choose an existing template*. **Template source:** *Upload a template file*.
   Upload `cloudformation/sql-lab.yaml` from this repo. Click **Next**.
3. **Stack name:** `sql-lab`. Review the parameters (the defaults are fine):
   - Database: `shopdb`, admin user `labadmin`, engine `16.6`
   - Capacity: min `0` (auto-pause), max `2`, pause after `600` seconds
4. Click **Next** twice, then **Submit**.
5. Watch the **Events** tab. Wait for `CREATE_COMPLETE` (10–15 minutes).
6. Open the **Outputs** tab and copy **SecretArn**.

## 2. Connect the Query Editor

1. Open **RDS → Query editor**.
2. **Database instance or cluster:** choose the `sql-lab-dbcluster-…` cluster.
3. **Database username:** *Connect with a Secrets Manager ARN*. Paste the **SecretArn**.
4. **Database name:** `shopdb`. Click **Connect to database**.

> If the database was paused, the first query may take 15–30 seconds while it resumes.

## 3. Create the tables and load the data

1. Open `sql/01-schema.sql`, copy everything, paste it into the editor and click **Run**.
2. Do the same with `sql/02-seed-data.sql`.
3. Check: `SELECT COUNT(*) FROM order_items;` should return **32**.

> The Query Editor runs the whole script for you. Only the CLI Data API needs one statement
> per call, which is why `run_sql.py` exists.

## 4. Work through the lessons

Open each file in `sql/lessons/`, paste one query at a time and click **Run**. Use **Save** to
keep favourite queries, and check the **Recent** tab to see your history.

## 5. Explore what CloudFormation created

- **CloudFormation → sql-lab → Resources:** the 7 resources and their physical IDs
- **VPC → Your VPCs:** `sql-lab-vpc` with two private subnets and no internet gateway
- **RDS → Databases:** the cluster with *Serverless v2 (0 - 2 ACUs)* capacity
- **Secrets Manager:** the `rds!cluster-…` secret holding the generated password
- **CloudWatch → Metrics → RDS:** `ServerlessDatabaseCapacity` drops to 0 when paused

## 6. Delete the stack

**CloudFormation → sql-lab → Delete**. Wait for `DELETE_COMPLETE`.
