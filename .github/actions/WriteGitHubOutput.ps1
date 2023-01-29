function Write-GitHubOutput
{
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Collections.Specialized.OrderedDictionary]$outputList
    )

    [string[]]$output = $outputList.GetEnumerator() | ForEach-Object {
        [string]$key = $_.Key
        $value = $_.Value

        if ($value -isnot [Array])
        {
            Write-Output "$key=$value"
            return
        }

        Write-Output "$key<<EOF"
        Write-Output $value
        Write-Output 'EOF'
    }

    $output | ForEach-Object { Write-Verbose $_ }

    if ($Env:GITHUB_ACTIONS)
    {
        Write-Verbose 'Set GITHUB_OUTPUT'
        $output | Out-File $Env:GITHUB_OUTPUT -Append
    }
}
