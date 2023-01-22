[CmdletBinding()]
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
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$lineList
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'lines' = $lineList
    }

    return $outputs
}

[string[]]$lines = dotnet msbuild -nologo -target:$target | ForEach-Object { $_.Trim() }

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -LineList $lines
Write-GitHubOutput -OutputList $outputs
