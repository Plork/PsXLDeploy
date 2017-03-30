function Start-XLDMaintenance
{
    <#
        .SYNOPSIS
        Put server into MAINTENANCE mode (prepare for shutdown).

        .EXAMPLE
        Start-XLDMaintenance

        .LINK
        https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()

    $null = Invoke-XLDRestMethod -Resource 'server/maintenance/start' -Method Post

    return Get-XLDServerState
}
