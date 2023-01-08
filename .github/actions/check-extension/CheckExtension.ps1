[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]$paths = '*,Source/*'
)

function Test-Extension
{
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$extension
    )

    foreach ($filePath in $path)
    {
        if (Test-Path "$(Join-Path $filePath '*').$extension")
        {
            return $true
        }
    }

    return $false
}

function Get-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$path
    )

    [Collections.Specialized.OrderedDictionary]$outputs = [Ordered]@{
        'dotnet' = Test-Extension -Path $path -Extension 'sln'
        'powershell' = Test-Extension -Path $path -Extension 'ps1'
        'python' = Test-Extension -Path $path -Extension 'py'
        'html' = Test-Extension -Path $path -Extension 'html'
        'css' = Test-Extension -Path $path -Extension 'css'
        'javascript' = Test-Extension -Path $path -Extension 'js'
        'typescript' = Test-Extension -Path $path -Extension 'ts'
        'json' = Test-Extension -Path $path -Extension 'json'
        'yaml' = Test-Extension -Path $path -Extension 'yml'
        'markdown' = Test-Extension -Path $path -Extension 'md'
        'docker' = Test-Path 'Dockerfile'
        'nuget' = Test-Extension -Path $path -Extension 'nupkg'
    }

    return $outputs
}

Get-ChildItem

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/WriteGitHubOutput.ps1

[string[]]$pathList = $paths.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)
$pathList | ForEach-Object { Write-Verbose "Path: $_" }

[Collections.Specialized.OrderedDictionary]$outputs = Get-GitHubOutput -Path $pathList

Write-GitHubOutput -OutputList $outputs
