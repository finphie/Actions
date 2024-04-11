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

[string]$dotnetVersion = dotnet --version
Write-Verbose ".NET version: $dotnetVersion"

[Version]$version = ($dotnetVersion -Split '-')[0]
[string]$terminalLogger = ''

if ($version.Major -ge 9)
{
    $terminalLogger = '--tl:off'
}

[string[]]$lines = dotnet msbuild -nologo -target:$target $terminalLogger | ForEach-Object { $_.Trim() }

[OrderedDictionary]$outputs = Get-GitHubOutput -LineList $lines
Write-GitHubOutput -OutputList $outputs
