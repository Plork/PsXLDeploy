function Stop-XLDMaintenance
{
    <#
        .SYNOPSIS
        Put server into RUNNING mode.

        .EXAMPLE
        Stop-XLDMaintenance

        .LINK
        https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()

    $null = Invoke-XLDRestMethod -Resource 'server/maintenance/stop' -Method Post

    return Get-XLDServerState
}
