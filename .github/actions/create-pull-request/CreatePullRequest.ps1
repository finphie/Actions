[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage,

    [ValidateNotNullOrEmpty()]
    [string]$branch = 'create-pull-request',

    [string]$labels = ''
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1
. $rootPath/Utility.ps1

# 差分なしの場合、以降の処理をスキップして正常終了する。
if (!(Test-Diff))
{
    Write-Verbose 'Skip'
    exit
}

Set-GitConfig

[string]$date = Get-Date -AsUTC -Format 'yyyyMMddHHmmss'
[string]$branchName = "$branch/$date"
Invoke-GitCommitAndPush -CommitMessage $commitMessage -BranchName $branchName

Write-Verbose 'Create pull request'

[string]$labelList = $labels -eq '' ? '' : ((Get-List -Value $labels) -Join ',')
Write-Verbose "Label: $labelList"

if ($labelList -eq '')
{
    gh pr create --fill
}
else
{
    gh pr create --fill --label $labelList
}