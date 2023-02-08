using namespace System.Collections.Specialized

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$target
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$lineList
    )

    [OrderedDictionary]$outputs = [Ordered]@{
        'lines' = $lineList
    }

    return $outputs
}

[string[]]$lines = dotnet msbuild -nologo -target:$target | ForEach-Object { $_.Trim() }

[OrderedDictionary]$outputs = Get-GitHubOutput -LineList $lines
Write-GitHubOutput -OutputList $outputs
