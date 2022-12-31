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
        [string[]]$repositories
    )

    Write-Output 'repositories<<EOF'
    $repositories | ForEach-Object { Write-Output $_ }
    Write-Output 'EOF'
}

$repositories = gh repo list `
    --archived=$archived `
    --fork=$fork `
    --language "$language" `
    --limit=$limit `
    --no-archived=$noArchived `
    --source=$source `
    --visibility $visibility `
    --json nameWithOwner `
    --jq '.[].nameWithOwner'

# 除外関連
if ($exclude -ne '')
{
    $excludeRepositories = $exclude -Split "[, `r`n]"
    $repositories = $repositories | Where-Object { !($_ -in $excludeRepositories) }
}

$output = Write-RepositoryNames $repositories
Write-Output ''
Write-Output $output

# GitHub Actionsで実行している場合
if ($Env:GITHUB_ACTIONS)
{
    Write-Output 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
