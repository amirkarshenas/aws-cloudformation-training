# Hello/Echo .NET Lambda with Function URL — Design

**Date:** 2026-08-12
**Status:** Approved by user (conversation, 2026-08-12)

## Goal

First Lambda for a user new to AWS: an HTTP-triggered .NET function that
returns a JSON greeting and echoes the request details, exposed via a Lambda
Function URL. Deployed with the existing CDK C# app (`cdk/`).

## Decisions (from interview)

- **Trigger:** HTTP request.
- **Front door:** Lambda Function URL (not API Gateway) — zero cost, simplest.
- **Auth:** `NONE` — the URL is publicly callable. Acceptable for a
  hello-world in the dev sandbox (account 123456789012); real workloads will
  use IAM auth or API Gateway.
- **Behavior:** returns JSON: greeting (uses `?name=` query param, default
  "world"), plus echo of method, path, and query string.
- **Runtime:** .NET 8 (`dotnet8`), the current LTS Lambda managed runtime.

## Components

1. **`cdk/src/HelloLambda/`** — new C# project (added to `Cdk.sln`):
   - `HelloLambda.csproj` — net8.0, Amazon.Lambda.Core,
     Amazon.Lambda.APIGatewayEvents, Amazon.Lambda.Serialization.SystemTextJson.
   - `Function.cs` — handler
     `HelloLambda::HelloLambda.Function::FunctionHandler` taking
     `APIGatewayHttpApiV2ProxyRequest` (the payload format Function URLs use)
     and returning `APIGatewayHttpApiV2ProxyResponse`.
2. **`cdk/src/Cdk/CdkStack.cs`** — add:
   - Lambda `Function` (DOTNET_8, 256 MB, 10 s timeout,
     `Code.FromAsset("src/HelloLambda/bin/Release/net8.0/publish")`),
   - Function URL with `FunctionUrlAuthType.NONE`,
   - `CfnOutput` exposing the URL.
3. **`cdk/deploy.ps1`** — publishes the Lambda project
   (`dotnet publish -c Release`) then runs `cdk deploy`
   (`-SynthOnly` switch runs `cdk synth` instead).

## Error handling

- Script aborts on publish or deploy failure.
- Handler treats missing query parameters as defaults (no exceptions on
  empty requests).

## Testing / success criteria

- `cdk synth` succeeds and the template contains the function + URL.
- After `cdk deploy`: HTTP GET on the output URL (with `?name=...`) returns
  200 and the expected JSON echo.

## Out of scope

- API Gateway, custom domains, auth, CI/CD.
