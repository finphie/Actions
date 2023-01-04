function Write-GitHubOutput
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Hashtable]$outputList
    )

    $outputList
    [string[]]$output = ($outputList.GetEnumerator()) | ForEach-Object { "$($_.Key)=$($_.Value)" }

    if ($Env:GITHUB_ACTIONS)
    {
        Write-Verbose 'Set GITHUB_OUTPUT'
        $output | Out-File $Env:GITHUB_OUTPUT -Append
    }
}
