function Get-List
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$value,

        [switch]$withoutConnma
    )

    [char[]]$separator = @(' ', "`n", "`r")

    if (!$withoutConnma)
    {
        $separator += ','
    }

    return $value.Split($separator, [StringSplitOptions]::RemoveEmptyEntries)
}
