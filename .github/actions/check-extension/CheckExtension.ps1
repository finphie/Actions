[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" does not exist.')]
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
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [ValidateNotNullOrEmpty()]
        [string]$fileName = '*',

        [string]$extension,

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    [string]$fullFileName = $extension -eq '' ? $fileName : "$fileName.$extension"
    [string]$filePath = Join-Path $path $fullFileName

    # Test-Pathは隠しファイルを取得できない。
    [string[]]$files = (Get-ChildItem $filePath -File -Force -Recurse:$recurse -ErrorAction SilentlyContinue).FullName |
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
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container -IsValid }, ErrorMessage='"{0}" does not exist.')]
        [string]$path,

        [Parameter(Mandatory)]
        [bool]$recurse
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -Path $path -Extension 'sln' -Recurse $recurse
        'powershell' = Test-Extension -Path $path -Extension 'ps1' -Recurse $recurse
        'python' = Test-Extension -Path $path -Extension 'py' -Recurse $recurse
        'html' = Test-Extension -Path $path -Extension 'html' -Recurse $recurse
        'css' = Test-Extension -Path $path -Extension 'css' -Recurse $recurse
        'javascript' = Test-Extension -Path $path -Extension 'js' -Recurse $recurse
        'typescript' = Test-Extension -Path $path -Extension 'ts' -Recurse $recurse
        'json' = Test-Extension -Path $path -Extension 'json' -Recurse $recurse
        'yaml' = Test-Extension -Path $path -Extension 'yml' -Recurse $recurse
        'markdown' = Test-Extension -Path $path -Extension 'md' -Recurse $recurse
        'docker' = Test-Extension -Path $path -FileName 'Dockerfile' -Recurse $recurse
        'nuget' = Test-Extension -Path $path -Extension 'nupkg' -Recurse $recurse
        'zip' = Test-Extension -Path $path -Extension 'zip' -Recurse $recurse
        'exe' = Test-Extension -Path $path -Extension 'exe' -Recurse $recurse
    }

    return $outputs
}

Write-Verbose "Path: $path"
[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Path $path -Recurse $recurse

Write-GitHubOutput -OutputList $outputs
