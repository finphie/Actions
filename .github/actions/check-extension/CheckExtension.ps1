[CmdletBinding()]
param ()

function Check-Extension
{
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $extension
    )

    return (Test-Path "*.$extension") -or (Test-Path "Source/*.$extension")
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    param ()

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = $(Check-Extension -Extension 'sln')
        'powershell' = $(Check-Extension -Extension 'ps1')
        'python' = $(Check-Extension -Extension 'py')
        'html' = $(Check-Extension -Extension 'html')
        'javascript' = $(Check-Extension -Extension 'js')
        'typescript' = $(Check-Extension -Extension 'ts')
        'json' = $(Check-Extension -Extension 'json')
        'yaml' = $(Check-Extension -Extension 'yml')
        'markdown' = $(Check-Extension -Extension 'md')
        'docker' = $(Test-Path 'Dockerfile')
    }

    return $outputs
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput
Write-GitHubOutput -OutputList $outputs
