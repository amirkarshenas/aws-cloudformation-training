# AWS IaC — Initial Setup

Two Infrastructure-as-Code workflows, both using the SSO profile `my-sso-profile`
(account 123456789012, us-east-1 — substitute your own account ID). See
`docs/superpowers/specs/2026-08-12-aws-iac-setup-design.md` for background.

## Prerequisite: log in when your SSO token expires

```powershell
aws sso login --sso-session my-sso-profile
```

## Workflow 1 — Plain CloudFormation (templates/ + deploy.ps1)

Author YAML templates in `templates/`, then:

```powershell
# Validate only
.\deploy.ps1 -TemplateFile templates\sample-s3-bucket.yaml -StackName sample-s3-bucket -ValidateOnly

# Validate + deploy
.\deploy.ps1 -TemplateFile templates\sample-s3-bucket.yaml -StackName sample-s3-bucket
```

## Workflow 2 — AWS CDK in C# (cdk/)

Open `cdk/src/Cdk.sln` in Visual Studio and define resources in
`cdk/src/Cdk/CdkStack.cs`. Then from the `cdk/` folder:

```powershell
.\deploy.ps1              # publish Lambda code + cdk deploy
.\deploy.ps1 -SynthOnly   # publish + cdk synth (no AWS changes)
```

Or run the raw commands (`cdk synth` / `cdk diff` / `cdk deploy --profile my-sso-profile`)
after `dotnet publish src\HelloLambda\HelloLambda.csproj -c Release`.

The stack currently deploys `HelloLambda` (.NET 8 hello/echo function,
`src/HelloLambda/Function.cs`) behind a public Lambda Function URL — the URL
is printed as a stack output after deploy. The account/region is already
bootstrapped (`CDKToolkit` stack exists).

## Notes

- The SSO profile lives in `~/.aws/config` (`[profile my-sso-profile]` +
  `[sso-session my-sso-profile]`). SSO profiles must NOT be placed in
  `~/.aws/credentials` — that was the cause of the VS 2026 Toolkit
  "profile not loading" issue. Backups from the fix:
  `~/.aws/config.bak-2026-08-12`, `~/.aws/credentials.bak-2026-08-12`.
- `discover-aws-1/` is a legacy AWS Toolkit CloudFormation project
  (`.cfproj`); it is kept for reference but no longer used — modern Toolkits
  don't ship its build targets.
