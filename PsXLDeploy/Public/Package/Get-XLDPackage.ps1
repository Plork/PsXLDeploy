function Get-XLDPackage
{
    <#
            .SYNOPSIS
            Lists all application packages.

            .DESCRIPTION
            Lists all application packages that are present in the importablePackages directory on the XL Deploy Server.

            .EXAMPLE
            Get-XLDPackage

            .LINK
            https://docs.xebialabs.com/generated/xl-deploy/6.0.x/rest-api/
    #>
    [CmdletBinding()]
    param()
    BEGIN {
        $resource = 'package/import'
    }
    PROCESS
    {
        $Response = Invoke-XLDRestMethod -Resource $resource

        return $Response.list.string
    }
}
