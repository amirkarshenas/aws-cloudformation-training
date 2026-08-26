# AWS IaC Setup + Toolkit SSO Fix — Design

**Date:** 2026-08-12
**Status:** Approved by user (conversation, 2026-08-12)

## Problem

1. The AWS Toolkit extension in Visual Studio 2026 installs and completes SSO
   login, but the profile fails to load (including for AWS Transform). Root
   cause: the SSO profile `[my-sso-profile]` lives in `~/.aws/credentials`
   with `sso_session=...`, which the AWS CLI/SDK credential resolver does not
   allow — `sso_session`-based profiles are only valid in `~/.aws/config`.
   The profile is also missing the required `sso_account_id` and
   `sso_role_name` keys.
2. The existing `discover-aws-1.cfproj` CloudFormation project was generated
   from a legacy Toolkit template. It imports `cloudformation.targets` from
   VS2010-era Toolkit install paths that no modern Toolkit ships, so it cannot
   build in VS 2026.
3. The user wants a working Infrastructure-as-Code workflow using **both**
   plain CloudFormation templates (deployed via AWS CLI) **and** AWS CDK in C#.

## Environment (verified)

- Windows 11, Visual Studio 2026, AWS Toolkit extension installed, SSO login works.
- AWS CLI v2.36.21, Node.js v22.19.0, npm 11.11.1, .NET SDK 10.0.301.
- `~/.aws/config` contains a valid `[sso-session my-sso-profile]` block
  (start URL `https://d-9067e647d6.awsapps.com/start`, region `us-east-1`,
  scopes `sso:account:access,transform:read_write`).
- CDK CLI and SAM CLI are not installed.

## Design

### 1. Repair the SSO profile (prerequisite for everything else)

- Run `aws sso login --sso-session my-sso-profile` (interactive browser
  approval by the user).
- Determine `sso_account_id` and `sso_role_name` via
  `aws sso list-accounts` / `aws sso list-account-roles` with the session's
  access token.
- Rewrite `~/.aws/config` to contain both:
  - the existing `[sso-session my-sso-profile]` block (unchanged), and
  - a new `[profile my-sso-profile]` block with `sso_session`,
    `sso_account_id`, `sso_role_name`, `region = us-east-1`, `output = json`.
- Back up `~/.aws/credentials`, then remove the invalid `[my-sso-profile]`
  section from it (the explanatory comment header may stay).
- Verify: `aws sts get-caller-identity --profile my-sso-profile` returns the
  expected account. Restart Visual Studio and confirm the Toolkit loads the
  profile (user verification step).

### 2. CloudFormation + CLI workflow

- Retire `discover-aws-1.cfproj` / `.slnx`: the files stay in place untouched
  (nothing deleted), but the new workflow does not use them.
- New layout in the repo root:
  - `templates/` — CloudFormation templates authored in YAML. Seed with a
    small known-good example stack (e.g., a private S3 bucket) converted from
    the empty JSON starter.
  - `deploy.ps1` — thin wrapper around
    `aws cloudformation deploy --template-file <t> --stack-name <n> --profile my-sso-profile`,
    preceded by `aws cloudformation validate-template`.
- Templates are edited in VS 2026 as plain YAML; no extension dependency.

### 3. AWS CDK in C#

- Install CDK CLI: `npm install -g aws-cdk`.
- Scaffold `cdk/` folder via `cdk init app --language csharp`, producing a
  C# solution VS 2026 opens natively.
- One-time `cdk bootstrap` against the account/region (creates the CDKToolkit
  stack — real AWS resources; user is aware).
- Verify with `cdk synth`. No `cdk deploy` of app stacks unless the user
  explicitly asks.

## Error handling

- If SSO account/role enumeration fails, fall back to asking the user for
  their account ID and permission-set (role) name.
- Credentials file is backed up before modification; config rewrite preserves
  the existing sso-session block verbatim.
- If `cdk bootstrap` is not desired yet, sections 1–2 and `cdk synth` still
  work without it.

## Testing / success criteria

- `aws sts get-caller-identity --profile my-sso-profile` succeeds.
- AWS Toolkit in VS 2026 loads the profile and AWS Transform sees it (user
  confirms).
- `aws cloudformation validate-template` passes on the sample template.
- `cdk synth` produces a CloudFormation template without errors.

## Out of scope

- Deploying application stacks to AWS.
- SAM CLI, Terraform, or other IaC tools.
- Fixing/porting the legacy `.cfproj` project type.
