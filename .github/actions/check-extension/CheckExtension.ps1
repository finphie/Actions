[CmdletBinding()]
param ()

function Write-GitHubOutput
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $key,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $extension
    )

    $check = (Test-Path "*.$extension") -or (Test-Path "Source/*.$extension")
    Write-Output "$key=$($check)"
}

function Write-GitHubOutputExtension
{
    Write-GitHubOutput -Key 'dotnet' -Extension 'sln'
    Write-GitHubOutput -Key 'powershell' -Extension 'ps1'
    Write-GitHubOutput -Key 'python' -Extension 'py'
    Write-GitHubOutput -Key 'html' -Extension 'html'
    Write-GitHubOutput -Key 'javascript' -Extension 'js'
    Write-GitHubOutput -Key 'typescript' -Extension 'ts'
    Write-GitHubOutput -Key 'json' -Extension 'json'
    Write-GitHubOutput -Key 'yaml' -Extension 'yml'
    Write-GitHubOutput -Key 'markdown' -Extension 'md'
}

$output = Write-GitHubOutputExtension
Write-Output $output

if ($Env:GITHUB_ACTIONS)
{
    Write-Verbose 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
