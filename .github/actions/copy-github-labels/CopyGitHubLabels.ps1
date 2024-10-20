[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$repositories,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$sourceRepository,

    [switch]$delete
)

[string]$rootPath = Split-Path $PSScriptRoot
. $rootPath/Utility.ps1

function Get-GitHubLabelList
{
    [CmdletBinding()]
    [OutputType([Hashtable[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$repository
    )

    [string]$json = gh label list --repo $repository --json name,description,color
    [Hashtable[]]$labels = $json | ConvertFrom-Json -AsHashtable

    return $labels
}

function New-GitHubLabel
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$repository,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Hashtable]$source
    )

    Write-Verbose "Create label: $($source['name'])"

    if (!$PSCmdlet.ShouldProcess('gh label create'))
    {
        return
    }

    gh label create $source['name'] --repo $repository --description $source['description'] --color $source['color']
}

function Update-GitHubLabel
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$repository,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Hashtable]$label
    )

    Write-Verbose "Update label: $($label['name'])"

    if (!$PSCmdlet.ShouldProcess('gh label edit'))
    {
        return
    }

    gh label edit $label['name'] --repo $repository --description $label['description'] --color $label['color']
}

function Remove-GitHubLabel
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$repository,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [string]$labelName
    )

    Write-Verbose "Delete label: $labelName"

    if (!$PSCmdlet.ShouldProcess('gh label delete'))
    {
        return
    }

    gh label delete $labelName --repo $repository --yes
}

Write-Verbose "Source: $sourceRepository"
Write-Verbose "DryRun: $($PSBoundParameters.ContainsKey('WhatIf'))"

gh label list --repo $sourceRepository

Write-Output ''

[string[]]$repositoryList = Get-List -Value $repositories
[Hashtable[]]$sourceLabels = Get-GitHubLabelList -Repository $sourceRepository

foreach ($repository in $repositoryList)
{
    Write-Verbose $repository

    [Hashtable]$labels = @{}
    Get-GitHubLabelList -Repository $repository | ForEach-Object { $labels[$_['name']] = $_ }

    foreach ($sourceLabel in $sourceLabels)
    {
        [string]$sourceLabelName = $sourceLabel['name']
        [Hashtable]$label = $labels[$sourceLabelName]

        if ($null -eq $label)
        {
            New-GitHubLabel -Repository $repository -Source $sourceLabel
            continue
        }

        $labels.Remove($sourceLabelName)

        if ($label['description'] -eq $sourceLabel['description'] -and $label['color'] -eq $sourceLabel['color'])
        {
            continue
        }

        Update-GitHubLabel -Repository $repository -Label $label
    }

    if (!$delete)
    {
        continue
    }

    foreach ($labelToDelete in $labels.GetEnumerator())
    {
        Remove-GitHubLabel -Repository $repository -LabelName $labelToDelete.Key
    }
}
