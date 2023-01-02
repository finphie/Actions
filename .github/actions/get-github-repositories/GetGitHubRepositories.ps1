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

function Write-RepositoryNames
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

[string[]]$repositories = gh repo list `
    --archived=$archived `
    --fork=$fork `
    --language `"$language`" `
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

[string[]]$output = Write-RepositoryNames -Repositories $repositories
Write-Output ''
Write-Output $output

if ($Env:GITHUB_ACTIONS)
{
    Write-Output 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
