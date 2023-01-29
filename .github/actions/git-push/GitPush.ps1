[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$commitMessage
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1

# 差分なしの場合、以降の処理をスキップして正常終了する。
if (!(Test-Diff))
{
    Write-Verbose 'Skip'
    exit
}

Set-GitConfig
Invoke-GitCommitAndPush -CommitMessage $commitMessage

exit
