using namespace System.Collections.Specialized

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ $_ -match '^[^/]+(/[^/]+)?$' }, ErrorMessage='"{0}" is invalid.')]
    [string]$repository
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
        [string]$repositoryName
    )

    [OrderedDictionary]$outputs = [Ordered]@{
        'repository-name' = $repositoryName
    }

    return $outputs
}

[string]$repositoryName = $repository.Contains('/') ? ($repository -Split '/')[1] : $repository
[OrderedDictionary]$outputs = Get-GitHubOutput -RepositoryName $repositoryName

Write-GitHubOutput -OutputList $outputs
