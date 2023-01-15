function Get-List
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$value
    )

    return $value.Split([char[]]@(',', ' ', "`n", "`r"), [StringSplitOptions]::RemoveEmptyEntries)
}
