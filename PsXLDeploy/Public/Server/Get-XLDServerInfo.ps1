function Get-XLDServerInfo
{
    <#
            .SYNOPSIS
            Returns information about the configuration of the sever.

            .DESCRIPTION
            Returns information about the configuration of the sever. For example: version, plugins, and classpath.

            .EXAMPLE
            Get-XLDServerInfo

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()

    $Response = Invoke-XLDRestMethod -Resource 'server/info'

    $Hash = [ordered]@{
        classpath = $Response.'server-info'.classpath | Select-Object -ExpandProperty classpath-entry
        plugins   = $Response.'server-info'.plugins.'plugin-info'
        version   = $Response.'server-info'.version
    }
    $ServerInfo = New-Object -TypeName psobject -Property $Hash

    return $ServerInfo
}
