param (
    [Parameter(Mandatory)]
    [string]$repositories,

    [Parameter(Mandatory)]
    [string]$sourceRepository
)

Write-Output $sourceRepository
gh label list --repo $sourceRepository

$repositoryList = $repositories -Split "[, `r`n]"

Write-Output ''
Write-Output 'Clone labels'

foreach ($repository in $repositoryList)
{
    Write-Output $repository
    gh label clone $sourceRepository --force --repo $repository
}
