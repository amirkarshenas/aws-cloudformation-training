<#
.SYNOPSIS
    Publishes the Lambda project, then deploys the CDK stack.

.EXAMPLE
    .\deploy.ps1              # publish + cdk deploy
    .\deploy.ps1 -SynthOnly   # publish + cdk synth (no AWS changes)
#>
param(
    [switch]$SynthOnly,
    [string]$AwsProfile = "my-sso-profile"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$env:AWS_PROFILE = $AwsProfile

Write-Host "Publishing HelloLambda ..." -ForegroundColor Cyan
dotnet publish src/HelloLambda/HelloLambda.csproj -c Release
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed." }

if ($SynthOnly) {
    cdk synth
} else {
    cdk deploy --require-approval never
}
if ($LASTEXITCODE -ne 0) { throw "cdk command failed." }
