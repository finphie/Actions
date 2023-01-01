param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$repositories,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$sourceRepository
)

Write-Output $sourceRepository
gh label list --repo $sourceRepository

[string[]]$repositoryList = $repositories.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)

Write-Output ''
Write-Output 'Clone labels'

foreach ($repository in $repositoryList)
{
    Write-Output $repository
    gh label clone $sourceRepository --force --repo $repository
}
