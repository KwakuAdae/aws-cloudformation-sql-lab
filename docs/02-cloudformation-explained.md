# The CloudFormation Template Explained

A walkthrough of [`cloudformation/sql-lab.yaml`](../cloudformation/sql-lab.yaml).

## Template sections

```yaml
AWSTemplateFormatVersion: "2010-09-09"   # the only valid version
Description: ...                         # shown in the console
Metadata:   ...                          # console parameter grouping
Parameters: ...                          # inputs
Resources:  ...                          # what to create (the only required section)
Outputs:    ...                          # values to read after deployment
```

## Parameters

```yaml
MinCapacity:
  Type: Number
  Default: 0
  MinValue: 0
  MaxValue: 4
```

Parameters make one template reusable. `Default`, `AllowedValues`, `AllowedPattern`,
`MinValue` and `MaxValue` are checked **before** anything is created, so typos fail fast.
Override them at deploy time:

```bash
aws cloudformation deploy ... --parameter-overrides MaxCapacity=4 DatabaseName=salesdb
```

## Intrinsic functions used

| Function | Example | Result |
|----------|---------|--------|
| `!Ref` (parameter) | `!Ref DatabaseName` | `shopdb` |
| `!Ref` (resource) | `!Ref Vpc` | the VPC ID, e.g. `vpc-0abc…` |
| `!GetAtt` | `!GetAtt DbCluster.Endpoint.Address` | an attribute of a resource |
| `!GetAtt` (nested) | `!GetAtt DbCluster.MasterUserSecret.SecretArn` | ARN of the RDS-managed secret |
| `!Sub` | `!Sub "${AWS::StackName}-vpc"` | `sql-lab-vpc` |
| `!GetAZs` + `!Select` | `!Select [0, !GetAZs ""]` | first Availability Zone in the region |
| `!Cidr` | `!Select [0, !Cidr [!Ref VpcCidr, 4, 8]]` | `10.20.0.0/24` (the 1st of 4 /24 blocks) |

`AWS::StackName`, `AWS::Region`, `AWS::AccountId` and `AWS::Partition` are **pseudo
parameters**, available in every template.

## Resources and dependencies

```
Vpc ──┬─▶ PrivateSubnetA ─┐
      ├─▶ PrivateSubnetB ─┴─▶ DbSubnetGroup ─┐
      └─▶ DbSecurityGroup ───────────────────┴─▶ DbCluster ─▶ DbInstance
```

CloudFormation works out this order from the `!Ref`s, so no `DependsOn` is needed. It creates
independent resources in parallel and deletes in the reverse order.

### Why two subnets?

An RDS DB subnet group must span **at least two Availability Zones**, even when you run a single
instance, so Aurora can fail over or place replicas there later.

### Why no inbound security group rules?

The Data API and Query Editor reach the database through an AWS-managed HTTPS endpoint, not
through your VPC. With no internet gateway, no public IP and no inbound rules, there is no
network path to the database at all, which is a strong default.

### `DBCluster` + `DBInstance`

Aurora separates **storage** (the cluster: shared, replicated six ways across three AZs) from
**compute** (instances). `DBInstanceClass: db.serverless` makes the instance Serverless v2, which
scales in 0.5-ACU steps between `MinCapacity` and `MaxCapacity`.

### `ManageMasterUserPassword: true`

RDS generates a strong password and stores it in **Secrets Manager**, so it never appears in the
template, parameters or stack events. The Data API and Query Editor authenticate with the
secret's ARN.

### `DeletionPolicy` and `UpdateReplacePolicy`

| Value | When the stack is deleted or the resource replaced |
|-------|-------------------------------------------|
| `Delete` | the resource is deleted (used here, so the lab cleans up completely) |
| `Snapshot` | a final snapshot is taken first (**the default for RDS clusters**, recommended for real data) |
| `Retain` | the resource is kept and removed from the stack |

For production databases use `Snapshot` or `Retain`, plus `DeletionProtection: true`.

## Outputs

Outputs expose values the scripts need (`ClusterArn`, `SecretArn`, `DatabaseName`). You can also
`Export` an output so another stack can import it with `!ImportValue`. That's how a separate
"application" stack could find this database.

## Stack lifecycle commands

```bash
aws cloudformation validate-template --template-body file://cloudformation/sql-lab.yaml
aws cloudformation deploy --stack-name sql-lab --template-file cloudformation/sql-lab.yaml
aws cloudformation describe-stack-events --stack-name sql-lab --max-items 10
aws cloudformation describe-stacks --stack-name sql-lab --query 'Stacks[0].Outputs'
aws cloudformation create-change-set ...    # preview an update
aws cloudformation detect-stack-drift --stack-name sql-lab
aws cloudformation delete-stack --stack-name sql-lab
```
