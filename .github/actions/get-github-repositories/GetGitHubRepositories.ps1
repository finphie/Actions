[CmdletBinding()]
param (
    [switch]$archived,
    [switch]$fork,
    [string]$language = '',

    [ValidateRange('Positive')]
    [int]$limit = 1000,

    [switch]$noArchived,
    [switch]$source,

    [ValidateSet('public', 'private', 'internal')]
    [string]$visibility = 'public',

    [string]$exclude = ''
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$repositories
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'repositories' = $repositories
    }

    return $outputs
}

[string[]]$repositories = gh repo list `
    --archived=$archived `
    --fork=$fork `
    --language $language `
    --limit=$limit `
    --no-archived=$noArchived `
    --source=$source `
    --visibility $visibility `
    --json nameWithOwner `
    --jq '.[].nameWithOwner'

# 除外関連
if ($exclude -ne '')
{
    [string[]]$excludeRepositories = Get-List -Value $exclude
    $repositories = $repositories | Where-Object { !($_ -in $excludeRepositories) }
}

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Repositories $repositories
Write-GitHubOutput -OutputList $outputs
