[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$repositories,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$sourceRepository
)

Write-Verbose $sourceRepository
gh label list --repo $sourceRepository

[string[]]$repositoryList = $repositories.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)

Write-Verbose 'Clone labels'

foreach ($repository in $repositoryList)
{
    Write-Verbose $repository
    gh label clone $sourceRepository --force --repo $repository
}
