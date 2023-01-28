﻿[CmdletBinding(SupportsShouldProcess)]
param (
    [ValidateScript({ Test-Path $_ -PathType Leaf -IsValid }, ErrorMessage='"{0}" is invalid.')]
    [string]$outputFileName= 'repository.json',

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$solutionName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$projects
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1

[string[]]$projectList = Get-List -Value $projects -WithoutConnma

[Management.Automation.OrderedHashtable]$output = [Ordered]@{
    'Projects' = [Ordered]@{
        'Console' = @()
        'Windows' = @()
        'Android' = @()
        'AspNet' = @()
        'BlazorWebAssembly' = @()
    }
}

if (Test-Path $outputFileName -PathType Leaf)
{
    $output = Get-Content $outputFileName | ConvertFrom-Json -AsHashtable
}

foreach ($project in $projectList)
{
    #[string]$value = $line.Trim()

    if (!$project.StartsWith($solutionName))
    {
        continue
    }

    $projectName, $platform = $project -Split ','

    # 不明なプラットフォームの場合
    if ($platform -eq '')
    {
        Write-Verbose "Unknown platform: $projectName"
        continue
    }

    # 該当するプラットフォームが存在しない場合
    if (!$output.Projects.Contains($platform))
    {
        Write-Error "Error: ''$platform' is not supported."
        return
    }

    # プロジェクト情報が既に存在する場合
    if ($output.Projects[$platform] -contains $projectName)
    {
        Write-Verbose "Skip: $projectName, $platform"
        continue
    }

    $output.Projects[$platform] += $projectName
    $output.Projects[$platform] = ($output.Projects[$platform] | Sort-Object) -as [string[]]
}

$output | ConvertTo-Json | Out-File $outputFileName
