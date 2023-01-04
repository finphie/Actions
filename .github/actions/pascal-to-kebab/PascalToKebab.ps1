[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$text
)

[string]$result = [Regex]::Replace($text, '(?<=.)(?=[A-Z])', '-').ToLower() -Replace '-+', '-'
[string]$output = "text=$result"

Write-Verbose $output

if ($Env:GITHUB_ACTIONS)
{
    Write-Verbose 'Set GITHUB_OUTPUT'
    $output | Out-File $Env:GITHUB_OUTPUT -Append
}
