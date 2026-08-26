# AWS CloudFormation & CDK Training

A hands-on training repository for learning **Infrastructure as Code (IaC) on AWS**.
It demonstrates the same goal — deploying real AWS resources — through two different
workflows, so you can compare them side by side:

1. **Plain CloudFormation** — hand-written YAML templates deployed with the AWS CLI
2. **AWS CDK in C#** — infrastructure defined in .NET code that synthesizes to CloudFormation

Everything here is intended for **learning and experimentation**. Feel free to clone it,
break it, and rebuild it in your own AWS sandbox account.

## What's inside

```
Initial-Setup/
├── templates/          # Plain CloudFormation YAML (sample S3 bucket)
├── deploy.ps1          # Validate + deploy a template via the AWS CLI
├── cdk/                # AWS CDK app in C# (.NET)
│   ├── src/Cdk/        # The CDK stack definition (CdkStack.cs)
│   ├── src/HelloLambda/# A .NET 8 hello/echo Lambda function
│   └── deploy.ps1      # Publish the Lambda + cdk deploy in one step
└── docs/               # Design notes explaining the decisions made
```

The CDK app deploys **HelloLambda** — a minimal .NET 8 Lambda exposed through a
public [Lambda Function URL](https://docs.aws.amazon.com/lambda/latest/dg/urls-invoke.html),
which is printed as a stack output after deploy.

## Prerequisites

- An AWS account you can experiment in (a personal or sandbox account — **not** production)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with a profile (this repo's scripts assume an SSO profile named `my-sso-profile` — adjust to your own)
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0) (for the CDK/Lambda workflow)
- [AWS CDK CLI](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html) (`npm install -g aws-cdk`), with your account/region [bootstrapped](https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html)
- PowerShell (the deploy scripts are written for Windows PowerShell / pwsh)

## Getting started

Start with [`Initial-Setup/README.md`](Initial-Setup/README.md) — it walks through both
workflows step by step, from `aws sso login` to a deployed stack.

Suggested learning path:

1. Read `Initial-Setup/templates/sample-s3-bucket.yaml` and deploy it with
   `deploy.ps1 -ValidateOnly` first, then for real. This teaches raw CloudFormation:
   parameters, resources, outputs, and stack lifecycle.
2. Open `Initial-Setup/cdk/src/Cdk.sln` and read `CdkStack.cs`. Run `cdk synth` and
   compare the generated template with what you wrote by hand in step 1.
3. Deploy the CDK stack, call the Lambda Function URL it outputs, then tear it down
   with `cdk destroy`.
4. Read the design docs in `Initial-Setup/docs/` to see *why* things are set up this way.

## Notes for learners

- All account IDs in this repo are placeholders (`123456789012`) — substitute your own.
- The sample Lambda uses a public Function URL with `NONE` auth. That's fine for a
  hello-world exercise; real workloads should use IAM auth or API Gateway.
- Remember to delete stacks when you're done (`cdk destroy`, or delete the stack in the
  CloudFormation console) to avoid charges.

## License

Provided as-is for educational purposes.
