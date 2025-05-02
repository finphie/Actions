using namespace System.Collections.Specialized

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$path,

    [switch]$recurse
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1
. $rootPath/WriteGitHubOutput.ps1

function Test-Extension
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$path,

        [ValidateNotNullOrEmpty()]
        [string]$fileName = '*',

        [ValidateNotNull()]
        [string[]]$extensions = @(),

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    [string[]]$include = $extensions | ForEach-Object { "$fileName.$_" }

    # Test-Pathは隠しファイルを取得できない。
    [string[]]$files = (Get-ChildItem (Join-Path $path '*') -File -Force -Recurse:$recurse -Include $include -ErrorAction SilentlyContinue).FullName |
        Where-Object { ($_ -Replace '\\', '/') -notlike '*/.git/*' }

    if ($files.Count -eq 0)
    {
        return $false
    }

    $files | ForEach-Object { Write-Verbose "File: $_" }
    return $true
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" is invalid.')]
        [string]$path,

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    [OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -Path $path -Extensions 'sln', 'slnx' -Recurse $recurse
        'powershell' = Test-Extension -Path $path -Extensions 'ps1' -Recurse $recurse
        'python' = Test-Extension -Path $path -Extensions 'py' -Recurse $recurse
        'html' = Test-Extension -Path $path -Extensions 'html' -Recurse $recurse
        'css' = Test-Extension -Path $path -Extensions 'css' -Recurse $recurse
        'javascript' = Test-Extension -Path $path -Extensions 'js' -Recurse $recurse
        'typescript' = Test-Extension -Path $path -Extensions 'ts' -Recurse $recurse
        'json' = Test-Extension -Path $path -Extensions 'json' -Recurse $recurse
        'yaml' = Test-Extension -Path $path -Extensions 'yml' -Recurse $recurse
        'markdown' = Test-Extension -Path $path -Extensions 'md' -Recurse $recurse
        'docker' = Test-Extension -Path $path -FileName 'Dockerfile' -Recurse $recurse
        'nuget' = Test-Extension -Path $path -Extensions 'nupkg' -Recurse $recurse
        'zip' = Test-Extension -Path $path -Extensions 'zip' -Recurse $recurse
        'exe' = Test-Extension -Path $path -Extensions 'exe' -Recurse $recurse
    }

    return $outputs
}

Write-Verbose "Path: $path"
[OrderedDictionary]$outputs = Get-GitHubOutput -Path $path -Recurse $recurse

Write-GitHubOutput -OutputList $outputs
