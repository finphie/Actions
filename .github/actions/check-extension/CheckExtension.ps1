[CmdletBinding()]
param ()

function Test-Extension
{
    [CmdletBinding()]
    [OutputType([bool])]
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
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param ()

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -Extension 'sln'
        'powershell' = Test-Extension -Extension 'ps1'
        'python' = Test-Extension -Extension 'py'
        'html' = Test-Extension -Extension 'html'
        'css' = Test-Extension -Extension 'css'
        'javascript' = Test-Extension -Extension 'js'
        'typescript' = Test-Extension -Extension 'ts'
        'json' = Test-Extension -Extension 'json'
        'yaml' = Test-Extension -Extension 'yml'
        'markdown' = Test-Extension -Extension 'md'
        'docker' = Test-Path 'Dockerfile'
    }

    return $outputs
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput
Write-GitHubOutput -OutputList $outputs
