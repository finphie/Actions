[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf }, ErrorMessage='"{0}" does not exist.')]
    [string]$filePath
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
        [string[]]$text
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'text' = $text
    }

    return $outputs
}


$text = Get-Content $filePath

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Text $text
Write-GitHubOutput -OutputList $outputs
