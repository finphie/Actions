[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$repositories,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$sourceRepository
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1

Write-Verbose $sourceRepository
gh label list --repo $sourceRepository

[string[]]$repositoryList = Get-List -Value $repositories

Write-Verbose 'Clone labels'

foreach ($repository in $repositoryList)
{
    Write-Verbose $repository
    gh label clone $sourceRepository --force --repo $repository
}

exit
