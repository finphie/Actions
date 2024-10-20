[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$sourcePath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container }, ErrorMessage='"{0}" does not exist.')]
    [string]$targetPath,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$settingsFilePath,

    [Parameter(ValueFromRemainingArguments)]
    [ValidateScript({ ($_ | ForEach-Object { Test-Path $_ }) -contains $true }, ErrorMessage='"{0}" does not exist.')]
    [string[]]$ignoreFiles = @()
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/GitCommand.ps1
. $rootPath/IO.ps1

function Get-CurrentGitHash
{
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$settingsFilePath
    )

    # 初回実行時などには、設定ファイルが存在しない場合がある。
    if (Test-Path $settingsFilePath -PathType Leaf)
    {
        [Hashtable]$json = Get-Content $settingsFilePath | ConvertFrom-Json -AsHashtable

        if ($json.ContainsKey('hash'))
        {
            return $json['hash']
        }
    }

    return Get-GitEmptyHash
}

[string]$settingsFullFilePath = Get-FilePath -Path $targetPath -ChildPath $settingsFilePath
[string]$hash = Get-CurrentGitHash -SettingsFilePath $settingsFullFilePath

Write-Verbose "DryRun: $($PSBoundParameters.ContainsKey('WhatIf'))"
Write-Verbose "Settings File: $settingsFullFilePath"
Write-Verbose "Hash: $hash"

[string[]]$sourceFileNames = Get-RepositoryFile -Path $sourcePath -Hash $hash
[string[]]$headSourceFileNames = Get-RepositoryFile -Path $sourcePath

[string[]]$fileNamesToDelete = ($sourceFileNames + $headSourceFileNames) | Select-Object -Unique
$fileNamesToDelete | ForEach-Object { Remove-File -FilePath (Join-Path $targetPath $_) }

$headSourceFileNames | ForEach-Object { Copy-File -SourceFilePath (Join-Path $sourcePath $_) -TargetFilePath (Join-Path $targetPath $_) }
$ignoreFiles | ForEach-Object { Remove-File -FilePath (Join-Path $targetPath $_) }

[string]$newHash = Get-HeadHash -Path $sourcePath
[Hashtable]$json = @{
    'hash' = $newHash
}

Write-Verbose "Write: $settingsFullFilePath"
$json | ConvertTo-Json | Out-File $settingsFullFilePath
