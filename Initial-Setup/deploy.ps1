<#
.SYNOPSIS
    Validates and deploys a CloudFormation template.

.EXAMPLE
    .\deploy.ps1 -TemplateFile templates\sample-s3-bucket.yaml -StackName sample-s3-bucket

.EXAMPLE
    .\deploy.ps1 -TemplateFile templates\sample-s3-bucket.yaml -StackName sample-s3-bucket -ValidateOnly
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$TemplateFile,

    [Parameter(Mandatory = $true)]
    [string]$StackName,

    [string]$AwsProfile = "my-sso-profile",

    [string]$Region = "us-east-1",

    # Extra parameter overrides, e.g. -ParameterOverrides @("BucketNameSuffix=my-suffix")
    [string[]]$ParameterOverrides = @(),

    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TemplateFile)) {
    throw "Template file not found: $TemplateFile"
}

Write-Host "Validating template $TemplateFile ..." -ForegroundColor Cyan
aws cloudformation validate-template `
    --template-body "file://$TemplateFile" `
    --profile $AwsProfile --region $Region | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Template validation failed." }
Write-Host "Template is valid." -ForegroundColor Green

if ($ValidateOnly) { return }

$deployArgs = @(
    "cloudformation", "deploy",
    "--template-file", $TemplateFile,
    "--stack-name", $StackName,
    "--profile", $AwsProfile,
    "--region", $Region,
    "--capabilities", "CAPABILITY_NAMED_IAM",
    "--no-fail-on-empty-changeset"
)
if ($ParameterOverrides.Count -gt 0) {
    $deployArgs += "--parameter-overrides"
    $deployArgs += $ParameterOverrides
}

Write-Host "Deploying stack '$StackName' ..." -ForegroundColor Cyan
aws @deployArgs
if ($LASTEXITCODE -ne 0) { throw "Deployment failed." }

Write-Host "Stack outputs:" -ForegroundColor Cyan
aws cloudformation describe-stacks --stack-name $StackName `
    --profile $AwsProfile --region $Region `
    --query "Stacks[0].Outputs" --output table
