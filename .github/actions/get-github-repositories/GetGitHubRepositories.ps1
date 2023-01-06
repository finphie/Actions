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

function Get-GitHubOutput
{
    [CmdletBinding()]
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

function Get-RepositoryNames
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$repositories
    )

    Write-Output 'repositories<<EOF'
    Write-Output $repositories
    Write-Output 'EOF'
}

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

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
    [string[]]$excludeRepositories = $exclude.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)
    $repositories = $repositories | Where-Object { !($_ -in $excludeRepositories) }
}

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Repositories $repositories
Write-GitHubOutput -OutputList $outputs
