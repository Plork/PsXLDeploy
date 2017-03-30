function Get-XLDServerState
{
    <#
            .SYNOPSIS
            Return information about current server state.

            .DESCRIPTION
            Return information about current server state (is it RUNNING or in MAINTENANCE mode).

            .EXAMPLE
            Get-XLDServerState

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()

    $Response = Invoke-XLDRestMethod -Resource 'server/state'

    return $Response.'server-state'.'current-mode'
}
